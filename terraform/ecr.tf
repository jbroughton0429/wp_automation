resource "aws_ecr_repository" "wordpress" {
  name = var.project
  image_tag_mutability = "MUTABLE"

  tags = local.infra_tags

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "local_file" "ecr_arn" {
  content = aws_ecr_repository.wordpress.arn
  filename = "./files/acr_arn"
}

resource "local_file" "ecr_url" {
  content = aws_ecr_repository.wordpress.repository_url
filename = "./files/ecr_url"
}
