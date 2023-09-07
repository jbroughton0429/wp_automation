provider "aws" {
  region = var.region
}

module "networking" {
  source = "./modules/networking"

  project              = var.project
  environment          = var.environment
  region               = var.region
  availability_zones   = var.availability_zones
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
}

resource "aws_security_group" "wordpress_task" {
  name = "Task Security Group"
  vpc_id  = module.networking.vpc_id

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


