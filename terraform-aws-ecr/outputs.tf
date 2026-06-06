output "repository_url" {
  description = "The URL of the repository"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_name" {
  description = "Name of the repository"
  value       = aws_ecr_repository.this.name
}
