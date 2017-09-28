provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file(var.google_key_file)}"
}

module "vpc" {
  source      = "../../../../terraform-modules/google/vpc"
  name        = "${var.vpc_name}"
  auto_subnet = "${var.auto_subnet}"
  subnets     = "${var.subnets}"
  sg_rules    = "${var.sg_rules}"
}

# Getting compute zones
data "google_compute_zones" "available" {}

resource "google_compute_instance_group" "bosh" {
  name = "bosh"
  zone = "${data.google_compute_zones.available.names[0]}"
  description = "BOSH instance group"
  network = "${module.vpc.vpc_link}"
  named_port {
    name = "https"
    port = 443
  }
}
