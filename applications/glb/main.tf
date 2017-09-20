module "vpc" {
  source       = "../terraform-modules/google/vpc"
  network_name = "${var.network_name}"
  auto_subnet  = "${var.auto_subnet}"
  subnets      = "${var.subnets}"
}

provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file(var.credentials)}"
}
