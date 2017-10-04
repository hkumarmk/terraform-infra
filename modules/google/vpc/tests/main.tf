module "vpc" {
  source      = "../"
  name        = "${var.name}"
  auto_subnet = "${var.auto_subnet}"
  subnets     = "${var.subnets}"
  routes      = "${var.routes}"
  firewall_rules    = "${var.firewall_rules}"
}

provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file(var.credentials)}"
}
