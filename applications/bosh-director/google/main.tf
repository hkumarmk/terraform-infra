terraform {
  backend "consul" {}
}


provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file(var.google_key_file)}"
}

# Read data from base_networking
data "terraform_remote_state" "base_networking" {
  backend = "consul"
  config = {
    address = "${var.tf_consul_address}"
    path = "${var.tf_base_networking_state_path}"
  }
}

module "firewall" {
  source      = "../../../modules/google/firewall"
  rules    = "${var.firewall_rules}"
  vpc_id = "${data.terraform_remote_state.base_networking.vpc_id}"
}

# Getting compute zones
data "google_compute_zones" "available" {}

resource "google_compute_instance_group" "bosh" {
  name = "bosh"
  zone = "${data.google_compute_zones.available.names[0]}"
  description = "BOSH instance group"
  network = "${data.terraform_remote_state.base_networking.vpc_link}"
  named_port {
    name = "https"
    port = 443
  }
}
