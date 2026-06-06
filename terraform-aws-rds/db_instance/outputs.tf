output "db_identifier" {
  description = "The identifier of the RDS instance"
  value       = aws_db_instance.this.identifier
}

output "db_address" {
  description = "The DNS address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = aws_db_instance.this.username
}

output "db_port" {
  description = "The port number the database instance is listening on"
  value       = aws_db_instance.this.port
}
