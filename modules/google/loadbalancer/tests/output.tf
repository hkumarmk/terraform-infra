output "vpc_subnets" {
  value = "${module.vpc.subnets}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
