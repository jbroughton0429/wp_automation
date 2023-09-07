provider "aws" {
  region = "eu-central-1"
  }

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.15.0"
    }
  }
}

resource "aws_kms_key" "wordpress" {
  description = "RDS Key for Wordpress"
}

resource "aws_db_instance" "wordpress" {
  allocated_storage             =  20
  identifier			= "wordpress"
  engine                        = "mysql"
  engine_version                = "5.7.43"
  instance_class                = "db.t3.micro"
  db_name                       = "wordpress"
  publicly_accessible           = "true"
  username                      = "kenny"
  password			= "Radio04Down!"
  skip_final_snapshot           = true
  tags 		                = local.infra_tags
}

resource "local_file" "dbhost" {
  content = aws_db_instance.wordpress.address
  filename = "database_host.txt"
}
