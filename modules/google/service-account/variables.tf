variable "rules" {
  type = "list"
  description = <<DESC
List of sg rules maps that is deployed within single network in the form of
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
rules = [
  {
    ports = "80,443"
    target_tags = "web"
    source_cidrs = "192.168.100.0/24, 192.168.101.0/24"
  },
  {
    protocol = "icmp"
  },
]
DESC
  default = []
}

variable "vpc_id" {
  description = "VPC(Network) ID. You may use vpc_id output from vpc module"
}
