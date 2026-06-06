output "variable_names" {
  description = "List of variable names created in the environment"
  value       = keys(var.variables)
}

output "environment" {
  description = "Name of the GitHub environment where variables were created"
  value       = var.environment
}

output "repository" {
  description = "Name of the GitHub repository where variables were created"
  value       = var.repository
}
