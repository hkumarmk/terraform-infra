project = "mcgcpcloud"
region = "us-central1"
credentials = "test_creds.json"
auto_subnet = "false"
name = "sg-test-vpc"
routes = [{
  name = "sg-test-route-1"
  next_hop_ip = "192.168.0.10"
  dest_range = "192.168.100.0/24"
  },
  {
  name = "sg-test-route-2"
  next_hop_ip = "192.168.0.11"
  dest_range = "192.168.101.0/24"
  priority = "10"
}]
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
