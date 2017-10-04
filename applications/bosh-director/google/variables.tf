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
    }
  ]
}

variable "project" {
  default = "mcgcpcloud"
}

variable "region" {}

variable "google_key_file" {}

variable "tf_base_networking_state_path" {
  description = "base_networking terraform state path"
}

variable "tf_consul_address" {
  description = "consul address that keep terraform states"
}
