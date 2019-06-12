provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file(var.credentials)}"
}

module "vpc" {
  source      = "../../vpc"
  name        = "${var.name}"
  auto_subnet = "${var.auto_subnet}"
  subnets     = "${var.subnets}"
  routes      = "${var.routes}"
}

module "firewall" {
  source = "../"
  vpc_id = "${module.vpc.vpc_id}"
  rules = "${var.rules}"
}