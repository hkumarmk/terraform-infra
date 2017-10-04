/* Setup instance group that may be used for backend services
rules = [
  {
    ports = "80,443"
    target_tags = "web"
    source_cidrs = "192.168.100.0/24"
  },
  {
    protocol = "icmp"
  },
]
*/
resource "google_compute_instance_group" "mod" {
  count = "${length(var.instance_group)}"
  name    = "${lookup(
  var.rules[count.index],
  "name",
  "sg-${join("-", compact(list(var.vpc_id,
             lookup(var.rules[count.index], "protocol", "tcp"),
             replace(lookup(var.rules[count.index], "ports", ""), ",", "-"),
             replace(lookup(var.rules[count.index], "source_tags", ""), ",", "-"),
             replace(lookup(var.rules[count.index], "target_tags", ""), ",", "-"),
             replace(lookup(var.rules[count.index], "source_cidrs", ""), "/[,//.]/", "-"))))}")}"
  #"sg-${google_compute_network.mod.id}-${lookup(var.rules[count.index], "protocol", "tcp")}-${replace(lookup(var.rules[count.index], "ports", ""), ",", "-")}-${replace(lookup(var.rules[count.index], "source_tags", ""), ",", "-")}-${replace(lookup(var.rules[count.index], "target_tags", ""), ",", "-")}-${replace(lookup(var.rules[count.index], "source_cidrs", ""), "[,/]", "-")}s")}"
  network = "${var.vpc_id}"
  zone  = "${var.zone}"
  instances = "${var.instances}"

  description = "${lookup(var.rules[count.index], "description", "")}"
  source_ranges = "${split(",", lookup(var.rules[count.index], "source_cidrs", "0.0.0.0/0"))}"
  source_tags = "${compact(split(",", lookup(var.rules[count.index], "source_tags", "")))}"
  target_tags = "${compact(split(",", lookup(var.rules[count.index], "target_tags", "")))}"
  allow {
    protocol = "${lookup(var.rules[count.index], "protocol", "tcp")}"
    ports = "${compact(split(",", lookup(var.rules[count.index], "ports", "")))}"
  }
}

