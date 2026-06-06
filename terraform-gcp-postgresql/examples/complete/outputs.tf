output "db_primary_private_ip_address" {
  value = module.postgresql.db_primary_private_ip_address
}

output "db_replica_private_ip_address" {
  value = module.postgresql.db_replica_private_ip_address
}

output "db_analytic_replica_private_ip_addresses" {
  value = module.postgresql.db_analytic_replica_private_ip_addresses
}

output "db_primary_connection_name" {
  value = module.postgresql.db_primary_connection_name
}

output "db_replica_connection_name" {
  value = module.postgresql.db_replica_connection_name
}

output "db_analytic_replica_connection_name" {
  value = module.postgresql.db_analytic_replica_connection_name
}

output "db_username" {
  value = module.postgresql.db_username
}

output "db_password" {
  value = module.postgresql.db_password
}

output "db_name" {
  value = module.postgresql.db_name
}
