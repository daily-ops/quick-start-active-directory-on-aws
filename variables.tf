variable "aws_region" {
  type = string
}

variable "dns_domain" {
  type = string
}

variable "recovery_password" {
  type = string
}

variable "domain_netbios_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}