output "elasticache_replication_group_primary_endpoint_address" {
  description = "The primary endpoint address of the ElastiCache replication group."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "elasticache_replication_group_reader_endpoint_address" {
  description = "The reader endpoint address of the ElastiCache replication group."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "elasticache_replication_group_configuration_endpoint_address" {
  description = "The configuration endpoint address of the ElastiCache replication group."
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}

output "elasticache_replication_group_port" {
  description = "The port on which the ElastiCache replication group is accessible."
  value       = aws_elasticache_replication_group.this.port
}

output "transition_encryption_auth_token" {
  description = "The authentication token for enabling encryption in transit for the ElastiCache replication group. This token is used to secure client-to-node and node-to-node communications."
  value       = try(random_string.this[0].result, null)
}
