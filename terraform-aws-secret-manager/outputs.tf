output "secrets" {
  description = "In format of map(string)"
  value       = aws_secretsmanager_secret_version.this
}
