output "endpoint" {
  description = "The cluster endpoint"
  value       = module.documentdb.endpoint
}

output "secret_arn" {
  description = "ARN of the connection secret"
  value       = module.documentdb.secret_arn
}

output "security_group_id" {
  description = "ID of the cluster security group"
  value       = module.documentdb.security_group_id
}
