output "name" {
  description = "Amplify App name"
  value       = aws_amplify_app.this.name
}

output "arn" {
  description = "Amplify App ARN"
  value       = aws_amplify_app.this.arn
}

output "id" {
  description = "Amplify App ID"
  value       = aws_amplify_app.this.id
}

output "backend_environment_name" {
  description = "Created backend environment name"
  value       = var.enable_backend ? aws_amplify_backend_environment.this[0].environment_name : null
}

output "backend_environment_arn" {
  description = "Created backend environment arn"
  value       = var.enable_backend ? aws_amplify_backend_environment.this[0].arn : null
}

output "amplify_app_backend_role_name" {
  description = "Created app backend role name"
  value       = aws_iam_role.amplify_backend.name
}

output "amplify_app_backend_role_arn" {
  description = "Created app backend role arn"
  value       = aws_iam_role.amplify_backend.arn
}

output "domain_name" {
  description = "Created domain name"
  value       = aws_amplify_domain_association.this.domain_name
}

output "webhook_url" {
  description = "To get the webhook url of amplify"
  value       = try(aws_amplify_webhook.main[0].url, null)
  sensitive   = true
}
