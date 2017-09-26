provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file(var.google_key_file)}"
}

module "vpc" {
  source      = "../../../terraform-modules/google/vpc"
  name        = "${var.name}"
  auto_subnet = "${var.auto_subnet}"
  subnets     = "${var.subnets}"
  sg_rules    = "${var.sg_rules}"
}

# Getting compute zones
data "google_compute_zones" "available" {}

# Create an instance group which will be added to service backend
# and the VMs will be added to it.
# tcp_proxy will forward external traffic to these VMs
resource "google_compute_instance_group" "glb" {
  name = "glb"
  zone = "${data.google_compute_zones.available.names[0]}"
  description = "GLB instance group"
  network = "${module.vpc.vpc_link}"
  named_port {
    name = "https"
    port = 443
  }
}

# Adding healthcheck for backend service
resource "google_compute_health_check" "ssl-check" {
  name = "glb-ssl-check"
  check_interval_sec = "${var.health_check_interval}"
  timeout_sec = "${var.health_check_timeout}"
  healthy_threshold = "${var.healthy_threshold}"
  unhealthy_threshold = "${var.unhealthy_threshold}"
  tcp_health_check {
    port = "${var.port}"
  }
}

resource "google_compute_backend_service" "glb-backend" {
  name        = "glb-backend"
  description = "GLB Applications backend"
  port_name   = "https"
  protocol    = "TCP"
  timeout_sec = "${var.backend_timeout}"
  enable_cdn  = false
  backend {
    group = "${google_compute_instance_group.glb.self_link}"
  }
  health_checks = ["${google_compute_health_check.ssl-check.self_link}"]
}

resource "google_compute_global_address" "glb-address" {
  name = "glb-address"
}

/*
Workaround for lack of tcp_proxy resource in terraform google provider
bug https://github.com/terraform-providers/terraform-provider-google/issues/363

Provision target tcp proxy and add forward rules to it using local-exec provisioning method.
*/
resource "null_resource" "provision-tcp-proxy" {
  # Trigger this resource if any changes in global_address
  triggers {
    global_address = "${google_compute_global_address.glb.id}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
set -e
export project_id="${var.project}"
export zone="${data.google_compute_zones.available.names[0]}"
export region="${var.region}"
gcloud config set project $${project_id}
gcloud config set compute/zone $${zone}
gcloud config set compute/region $${region}
gcloud auth activate-service-account --key-file ${var.google_key_file}
if [ $(gcloud compute target-tcp-proxies  list --quiet --filter='service:${google_compute_backend_service.glb-backend.name}' | wc -l) -eq 0 ]; then
  gcloud compute target-tcp-proxies create glb-target-proxy --backend-service glb-backend --proxy-header NONE;
fi
if [ $(gcloud beta compute forwarding-rules list --filter='target:glb-target-proxy' | wc -l) -eq 0 ]; then
  gcloud beta compute forwarding-rules create glb-forwarding-rule --global --target-tcp-proxy glb-target-proxy --address ${google_compute_global_address.glb.address} --ports 443
fi
SCRIPT
  }

  provisioner "local-exec" {
    command = <<SCRIPT
set -e
export project_id="${var.project}"
export zone="${data.google_compute_zones.available.names[0]}"
export region="${var.region}"
gcloud config set project $${project_id}
gcloud config set compute/zone $${zone}
gcloud config set compute/region $${region}
gcloud auth activate-service-account --key-file ${var.google_key_file}
if [ $(gcloud beta compute forwarding-rules list --filter='target:glb-target-proxy' | wc -l) -ne 0 ]; then
  gcloud beta compute forwarding-rules --quiet delete --global glb-forwarding-rule
fi
if [ $(gcloud compute target-tcp-proxies  list --quiet --filter='service:${google_compute_backend_service.glb-backend.name}' | wc -l) -ne 0 ]; then
  gcloud compute target-tcp-proxies --quiet delete glb-target-proxy
fi
SCRIPT
    when = "destroy"
  }
}
