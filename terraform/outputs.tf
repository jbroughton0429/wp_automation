output "arn" {
  description = "ECR ARN"
  value = aws_ecr_repository.wordpress.arn
}

output "repository_url" {
  description = "ECR Repo URL"
  value = aws_ecr_repository.wordpress.repository_url
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.wordpress.address
}


