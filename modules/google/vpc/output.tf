output "vpc_id" {
  value = "${google_compute_network.mod.id}"
}

output "vpc_link" {
  value = "${google_compute_network.mod.self_link}"
}

output "subnets" {
  value = ["${google_compute_subnetwork.mod.*.name}"]
}

output "subnet_cidr" {
  value = ["${google_compute_subnetwork.mod.*.ip_cidr_range}"]
}

output "routes" {
  value = ["${google_compute_route.mod.*.id}"]
}
