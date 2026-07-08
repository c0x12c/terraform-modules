output "cluster_id" {
  description = "The cluster identifier"
  value       = aws_docdb_cluster.this.id
}

output "cluster_arn" {
  description = "The cluster ARN"
  value       = aws_docdb_cluster.this.arn
}

output "cluster_resource_id" {
  description = "The immutable resource ID of the cluster"
  value       = aws_docdb_cluster.this.cluster_resource_id
}

output "endpoint" {
  description = "The cluster (writer) endpoint"
  value       = aws_docdb_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "The load-balanced reader endpoint"
  value       = aws_docdb_cluster.this.reader_endpoint
}

output "port" {
  description = "Port the cluster accepts connections on"
  value       = local.port
}

output "master_username" {
  description = "The master username"
  value       = aws_docdb_cluster.this.master_username
}

output "connection_uri" {
  description = "Ready-to-use MongoDB connection URI for the cluster"
  value       = local.connection_uri
  sensitive   = true
}

output "security_group_id" {
  description = "ID of the cluster security group"
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group used by the cluster"
  value       = local.db_subnet_group_name
}

output "cluster_parameter_group_name" {
  description = "Name of the cluster parameter group"
  value       = local.cluster_parameter_group_name
}

output "instances" {
  description = "List of cluster instance identifiers and endpoints"
  value = [
    for i in aws_docdb_cluster_instance.this : {
      identifier = i.identifier
      endpoint   = i.endpoint
      arn        = i.arn
    }
  ]
}

output "secret_arn" {
  description = "ARN of the connection secret in Secrets Manager (when create_secret is true)"
  value       = try(aws_secretsmanager_secret.this[0].arn, null)
}

output "secret_name" {
  description = "Name of the connection secret in Secrets Manager (when create_secret is true)"
  value       = try(aws_secretsmanager_secret.this[0].name, null)
}
