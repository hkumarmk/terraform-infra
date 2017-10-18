variable "firewall_rules" {
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
    },
    {
      ports = "22"
      target_tags = "bosh-bastion"
    },
    {
      protocol = "icmp"
      target_tags = "bosh-bastion"
    }
  ]
}

variable "project" {
  default = "mcgcpcloud"
}

variable "subnet" {
  description = "Bosh subnet"
  default = "192.168.100.0/24"
}
variable "region" {}

variable "zone" {}

variable "tf_base_networking_state_path" {
  description = "base_networking terraform state path"
}

variable "tf_consul_address" {
  description = "consul address that keep terraform states"
}

variable "latest_ubuntu" {
    type = "string"
    default = "ubuntu-1604-lts"
}

variable "prefix" {
  default = ""
}

variable "jumpbox" {
  description = "Whter to setup jumpbox or not"
  default = "true"
}
