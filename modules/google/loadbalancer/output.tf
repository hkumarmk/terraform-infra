output "sg_ids" {
  value = ["${google_compute_firewall.mod.*.id}"]
}
