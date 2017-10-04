variable "firewall_rules" {
  type = "list"
  default = []
}

variable "subnets" {
  type = "list"
  default = []
}

variable "auto_subnet" {
  default = "false"
}

variable "vpc_name" {
  default = "vpc"
}

variable "project" {
  default = "mcgcpcloud"
}

variable "region" {}

variable "google_key_file" {}
