# Setup vpc

resource "google_compute_network" "mod" {
  name                    = "${var.name}"
  auto_create_subnetworks = "${var.auto_subnet}"
}

/* Setup subnets if variable subnets defined
var.subnets is a list of subnet maps like below
  subnets = [{
    name = "subnet-1"
    cidr = "192.168.0.0/24"
    },
    {
      name = "subnet-2"
      cidr = "192.168.1.0/24"
    },
  ]
*/
resource "google_compute_subnetwork" "mod" {
  count         = "${var.auto_subnet ? 0 : length(var.subnets)}"
  name          = "${lookup(var.subnets[count.index], "name")}"
  ip_cidr_range = "${lookup(var.subnets[count.index], "cidr", "192.168.0.0/24")}"
  network       = "${google_compute_network.mod.self_link}"
}

/*
 Setup routes only if variable routes is defined.
 var.routes is a list of maps like
 {
  name        = route_name
  dest_range  = destination network range e.g 192.168.100.0/24
  next_hop_ip = next hope ip address
  priority    = OPTIONAL: Priority. Default: 100
}

Example:

routes = [{
    name = "route-1"
    next_hop_ip = "192.168.1.1"
    dest_range = "192.168.100.0/24"
    },
    {
    name = "route-2"
    next_hop_gateway = "192.168.0.1"
    dest_range = "192.168.101.0/24"
    }]
*/
resource "google_compute_route" "mod" {
  count       = "${length(var.routes)}"
  dest_range  = "${lookup(var.routes[count.index], "dest_range")}"
  name        = "${lookup(var.routes[count.index], "name")}"
  network     = "${google_compute_network.mod.self_link}"
  priority    = "${lookup(var.routes[count.index], "priority", 100)}"
  next_hop_ip = "${lookup(var.routes[count.index], "next_hop_ip", "")}"
}

/* Setup security group (firewall) rules

*/
resource "google_compute_firewall" "mod" {
  count = "${length(var.firewall_rules)}"
  name    = "${lookup(
  var.firewall_rules[count.index],
  "name",
  "sg-${join("-", compact(list(google_compute_network.mod.id,
             lookup(var.firewall_rules[count.index], "protocol", "tcp"),
             replace(lookup(var.firewall_rules[count.index], "ports", ""), ",", "-"),
             replace(lookup(var.firewall_rules[count.index], "source_tags", ""), ",", "-"),
             replace(lookup(var.firewall_rules[count.index], "target_tags", ""), ",", "-"),
             replace(lookup(var.firewall_rules[count.index], "source_cidrs", ""), "/[,//.]/", "-"))))}")}"
  #"sg-${google_compute_network.mod.id}-${lookup(var.firewall_rules[count.index], "protocol", "tcp")}-${replace(lookup(var.firewall_rules[count.index], "ports", ""), ",", "-")}-${replace(lookup(var.firewall_rules[count.index], "source_tags", ""), ",", "-")}-${replace(lookup(var.firewall_rules[count.index], "target_tags", ""), ",", "-")}-${replace(lookup(var.firewall_rules[count.index], "source_cidrs", ""), "[,/]", "-")}s")}"
  network = "${google_compute_network.mod.id}"
  description = "${lookup(var.firewall_rules[count.index], "description", "")}"
  source_ranges = "${split(",", lookup(var.firewall_rules[count.index], "source_cidrs", "0.0.0.0/0"))}"
  source_tags = "${compact(split(",", lookup(var.firewall_rules[count.index], "source_tags", "")))}"
  target_tags = "${compact(split(",", lookup(var.firewall_rules[count.index], "target_tags", "")))}"
  allow {
    protocol = "${lookup(var.firewall_rules[count.index], "protocol", "tcp")}"
    ports = "${compact(split(",", lookup(var.firewall_rules[count.index], "ports", "")))}"
  }
}
