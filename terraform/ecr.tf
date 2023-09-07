resource "aws_ecr_repository" "wordpress" {
  name = var.project
  image_tag_mutability = "MUTABLE"

  tags = local.infra_tags

  image_scanning_configuration {
    scan_on_push = true
  }
}

