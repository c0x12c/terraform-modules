locals {
  neo4j_password = var.neo4j_password != null ? var.neo4j_password : random_password.neo4j_password[0].result
  default_fqdn   = "${var.neo4j_dns_name}.${var.domain}"
  neo4j_fqdn     = var.neo4j_fqdn != "" ? var.neo4j_fqdn : local.default_fqdn
}
