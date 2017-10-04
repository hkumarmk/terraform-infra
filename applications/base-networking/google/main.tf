terraform {
  backend "consul" {}
}

provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file(var.google_key_file)}"
}

module "vpc" {
  source      = "../../../modules/google/vpc"
  name        = "${var.vpc_name}"
  auto_subnet = "${var.auto_subnet}"
  subnets     = "${var.subnets}"
  firewall_rules    = "${var.firewall_rules}"
}
