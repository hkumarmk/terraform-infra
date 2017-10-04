variable "name" {
  description = "Network name"
  default     = "default-vpc"
}

variable "auto_subnet" {
  description = "Whether to create subnets automatically on each gcp region"
  default     = true
}

variable "subnets" {
  type        = "list"
  description = "List of Subnets maps in form of {name=subnet_name, cidr=cidr}"

  default = [{
    name = "default-subnet"
    cidr = "192.168.0.0/24"
  }]
}

variable "routes" {
  type = "list"

  description = <<DESC
List of route maps in form of
{
  name        = route_name
  dest_range  = destination network range e.g 192.168.100.0/24
  next_hop_ip = next hope ip address
  priority    = OPTIONAL: Priority. Default: 100
}

Example:

routes = [{
    name = "default-route"
    next_hop_ip = "192.168.1.7"
    dest_range = "192.168.100.0/24"
    },
    {
    name = "default-route-2"
    next_hop_gateway = "192.168.0.1"
    dest_range = "192.168.101.0/24"
    }]

DESC

  default = []
}

variable "firewall_rules" {
  type = "list"
  description = <<DESC
List of sg rules maps in form of
{
  name = OPTIONAL name of sgrules, if not defined, automatically generated with combination of rules
  description = OPTIONAL description
  source_cidrs = OPTIONAL comma separated list of cidrs, default: 0.0.0.0/0
  source_tags = OPTIONAL comma separated list of source tags
  destination_tags = OPTIONAL comma separated list of destination tags
  protocol  = OPTIONAL default: tcp
  ports     = OPTIONAL comma separated list of ports
}

Example
firewall_rules = [
  {
    ports = "80,443"
    target_tags = "web"
    source_cidrs = "192.168.100.0/24"
  },
  {
    protocol = "icmp"
  },
]
DESC
  default = []
}
