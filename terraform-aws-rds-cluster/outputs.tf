output "cluster_id" {
  description = "The cluster identifier"
  value       = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "The cluster ARN"
  value       = aws_rds_cluster.this.arn
}

output "cluster_resource_id" {
  description = "The immutable resource ID of the cluster (used in IAM ABAC policies)"
  value       = aws_rds_cluster.this.cluster_resource_id
}

output "endpoint" {
  description = "The writer endpoint"
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "The load-balanced reader endpoint"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "port" {
  description = "Port the cluster accepts connections on"
  value       = aws_rds_cluster.this.port
}

output "database_name" {
  description = "The name of the initial database"
  value       = aws_rds_cluster.this.database_name
}

output "master_username" {
  description = "The master username"
  value       = aws_rds_cluster.this.master_username
}

output "master_user_secret_arn" {
  description = "ARN of the AWS-managed master user secret (when manage_master_user_password is true)"
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "ID of the cluster security group"
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group used by the cluster"
  value       = local.db_subnet_group_name
}

output "db_cluster_parameter_group_name" {
  description = "Name of the cluster parameter group"
  value       = local.db_cluster_parameter_group_name
}

output "db_parameter_group_name" {
  description = "Name of the instance parameter group (Aurora only)"
  value       = local.db_parameter_group_name
}

output "instances" {
  description = "Map of Aurora cluster instances by key. Empty for Multi-AZ DB cluster."
  value = {
    for k, v in aws_rds_cluster_instance.this : k => {
      identifier = v.identifier
      endpoint   = v.endpoint
      arn        = v.arn
    }
  }
}
