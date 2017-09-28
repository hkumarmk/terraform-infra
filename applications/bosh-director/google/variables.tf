variable "sg_rules" {
  type = "list"
  default = [
    {
      ports = "1-65535"
      source_tags = "internal"
    },
    {
      protocol = "icmp"
      source_tags = "internal"
    },
    {
      protocol = "udp"
      ports = "1-65535"
      source_tags = "internal"
    },
    {
      ports = "25555,6868"
      target_tags = "bosh-director"
    }
  ]
}

variable "subnets" {
  type = "list"
}

variable "auto_subnet" {
  default = "false"
}

variable "vpc_name" {
  default = "bosh-network"
}

variable "project" {
  default = "mcgcpcloud"
}

variable "region" {}

variable "google_key_file" {}
