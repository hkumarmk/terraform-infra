output "glb_ip" {
  value = "${google_compute_global_address.glb.address}"
}
