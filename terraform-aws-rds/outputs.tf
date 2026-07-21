output "main_address" {
  description = "The DNS address of the main RDS instance"
  value       = module.main_db_instance.db_address
}

output "replica_address" {
  description = "The DNS address of the first replica instance, or main instance if no replicas exist"
  value       = try(module.replica_db_instance[0].db_address, module.main_db_instance.db_address)
}

output "db_name" {
  description = "The name of the database"
  value       = module.main_db_instance.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = module.main_db_instance.db_username
}

output "db_password" {
  description = "The master password for the database"
  value = var.manage_master_user_password ? try(
    data.aws_secretsmanager_secret_version.managed[0].secret_string,
    null
  ) : try(random_password.this[0].result, null)
  sensitive = true
}

output "db_password_secret_arn" {
  description = "The ARN of the AWS Secrets Manager secret storing the database password"
  value       = var.manage_master_user_password ? module.main_db_instance.master_user_secret_arn : try(aws_secretsmanager_secret_version.this[0].arn, null)
}

output "db_port" {
  description = "The port number the database instance is listening on"
  value       = module.main_db_instance.db_port
}
