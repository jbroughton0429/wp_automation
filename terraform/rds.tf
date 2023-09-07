
#resource "aws_kms_key" "wordpress" {
#  description = "RDS Key for Wordpress"
#}

resource "aws_db_instance" "wordpress" {
  allocated_storage             =  20
  identifier			= "wordpress"
  engine                        = "mysql"
  engine_version                = "5.7.43"
  instance_class                = "db.t3.micro"
  db_name                       = "wordpress"
  publicly_accessible           = "false"
  username                      = var.db_user
  password                      = var.db_password
  skip_final_snapshot           = true
  db_subnet_group_name          = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids        = [aws_security_group.wordpress_db.id]
  tags 		                = local.infra_tags
}

resource "aws_db_subnet_group" "wordpress" {
  name = "wordpress"
  subnet_ids = module.networking.public_subnets_id

  tags = local.infra_tags
}

resource "local_file" "dbhost" {
  content = aws_db_instance.wordpress.address
  filename = "./files/database_host"
}
