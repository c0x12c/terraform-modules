output "password_secret_id" {
  description = "The password secret id"
  value       = aws_secretsmanager_secret.password.id
}
