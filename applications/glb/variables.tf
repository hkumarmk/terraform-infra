variable "project" {
  description = "Google cloud project name"
}

variable "region" {
  description = "Google cloud region"
}

variable "credentials" {
  description = "Google service account credentials"
}

variable "network_name" {
  description = "Network name"
  default     = "glb-net"
}

variable "auto_subnet" {
  description = "Whether to create subnets automatically on each gcp region"
  default     = true
}

variable "subnets" {
  description = "List of Subnets maps in form of {name=subnet_name, cidr=cidr}"
  type        = "list"

  default = [{
    name = "glb-subnet"
    cidr = "192.168.0.0/24"
  }]
}
