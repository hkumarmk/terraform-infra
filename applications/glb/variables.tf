variable "project" {
  description = "Google cloud project name"
  default = "mcgcpcloud"
}

variable "region" {
  description = "Google cloud region"
}

variable "name" {
  description = "VPC name"
  default     = "glb-vpc"
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

variable "sg_rules" {
  type = "list"
  default = [
    {
      ports = "22"
      target_tags = "bastion"
    },
    {
      protocol = "icmp"
      target_tags = "bastion"
    },
  ]
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  default = "1"
}

variable "health_check_timeout" {
  description = "Health check timeout in secs"
  default = "1"
}

variable "healthy_threshold" {
  description = "Consecutive sucesses required"
  default = "2"
}

variable "port" {
  description = "glb service port"
  default = "443"
}

variable "unhealthy_threshold" {
  description = "Consecutive failures required "
  default = "2"
}

variable "backend_timeout" {
  description = "The number of secs to wait for a backend to respond to a request before considering the request failed."
  default = "10"
}

variable "google_key_file" {
  description = "Google key file"
  default = "tests/test_creds.json"
}
