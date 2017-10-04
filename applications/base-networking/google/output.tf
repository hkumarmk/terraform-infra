output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_link" {
  value = "${module.vpc.vpc_link}"
}

output "subnets" {
  value = "${module.vpc.subnets}"
}

output "subnet_cidr" {
  value = "${module.vpc.subnet_cidr}"
}
