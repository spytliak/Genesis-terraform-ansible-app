variable "vpc_name" {
  description = "VPC for  Genesis DevOps School"
  type        = string
  default     = "VPC"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "Genesis"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.22.0/24",
    "10.0.33.0/24"
  ]
}

variable "enabled_dns_support" {
  type        = bool
  description = "enabling dns support"
  default = true
}

variable "enabled_dns_hostnames" {
  type        = bool
  description = "enabling dns hostnames"
  default = true
}