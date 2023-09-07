// variables.pkr.hcl

// Set Variables for Packer Build


variable "image" {
  type = string
  default = "ubuntu:focal"
  }
  
variable "repo" {
  type = string
  default = "913293700147.dkr.ecr.eu-central-1.amazonaws.com/wordpress"
  }
  
variable "login_server" {
  type = string
  default = "https://913293700147.dkr.ecr.eu-central-1.amazonaws.com/wordpress"
  }
