# The address of the main instance
output "main_address" {
  value = module.postgresql.main_address
}

# The endpoint of the first replica, fallback to the endpoint of main instance if there is no replica
output "replica_address" {
  value = module.postgresql.replica_address
}

# The database name
output "main_db_name" {
  value = module.postgresql.db_name
}

output "main_db_port" {
  value = module.postgresql.db_port
}
