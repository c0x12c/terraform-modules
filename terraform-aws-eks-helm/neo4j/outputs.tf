output "neo4j_username" {
  description = "The username for accessing the Neo4j database"
  value       = "neo4j"
}

output "neo4j_password" {
  description = "The password for accessing the Neo4j database"
  sensitive   = true
  value       = local.neo4j_password
}
