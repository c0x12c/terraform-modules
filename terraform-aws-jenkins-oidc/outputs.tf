# Provider

output "provider_arn" {
  description = "The ARN assigned by AWS for this provider."
  value       = module.provider.arn
}

output "provider_url" {
  description = "The URL of the identity provider. Corresponds to the iss claim."
  value       = module.provider.url
}

# Jenkins

output "role_arn" {
  description = "The role ARN of Jenkins OIDC."
  value       = aws_iam_role.oidc.arn
}
