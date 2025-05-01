variable "environment" {
  type    = list(string)
  default = ["dev", "prod", "test"]
}

variable "region" {
  type    = list(string)
  default = ["ap-south-1"]
}

variable "availabilityzone" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidr" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.201.0/24"]
}