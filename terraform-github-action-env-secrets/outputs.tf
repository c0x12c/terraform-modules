output "secret_names" {
  description = "List of secret names created in the environment"
  value       = keys(var.secrets)
}

output "environment" {
  description = "Name of the GitHub environment where secrets were created"
  value       = var.environment
}

output "repository" {
  description = "Name of the GitHub repository where secrets were created"
  value       = var.repository
}
