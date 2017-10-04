variable "project" {
  description = "Google cloud project name"
}

variable "region" {
  description = "Google cloud region"
}

variable "credentials" {
  description = "Google service account credentials"
}

variable "name" {
  default     = "test-vpc"
}

variable "auto_subnet" {
  default     = true
}

variable "subnets" {
  type        = "list"
  default = [{
    name = "test-subnet"
    cidr = "192.168.0.0/24"
  }]
}

variable "routes" {
  type = "list"
  default = []
}

variable "firewall_rules" {
  type = "list"
  default = []
}
