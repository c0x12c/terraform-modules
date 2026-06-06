output "db_primary_private_ip_address" {
  description = "The private IP address of primary instance."
  value       = google_sql_database_instance.primary.private_ip_address
}

output "db_replica_private_ip_address" {
  description = "The list of private IP address of replica instance. If there is no replica, use the primary instance's private IP address."
  value       = var.replica_count > 0 ? google_sql_database_instance.replica[*].private_ip_address : [google_sql_database_instance.primary.private_ip_address]
}

output "db_analytic_replica_private_ip_addresses" {
  description = "The list of private IP address of analytic replica instance."
  value       = google_sql_database_instance.analytic_replica[*].private_ip_address
}

output "db_primary_connection_name" {
  description = "The primary instance connection name."
  value       = google_sql_database_instance.primary.connection_name
}

output "db_replica_connection_name" {
  description = "The list of replica(s) connection name."
  value       = google_sql_database_instance.replica[*].connection_name
}

output "db_analytic_replica_connection_name" {
  description = "The list of analytic replica(s) connection name."
  value       = google_sql_database_instance.replica[*].connection_name
}

output "db_username" {
  description = "The database username."
  value       = var.username
}

output "db_password" {
  description = "The database password."
  value       = local.password
}

output "db_name" {
  description = "The database name."
  value       = var.db_name
}
