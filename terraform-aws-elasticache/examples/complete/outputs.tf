output "elasticache_replication_group_primary_endpoint_address" {
  value = module.redis.elasticache_replication_group_primary_endpoint_address
}

output "elasticache_replication_group_reader_endpoint_address" {
  value = module.redis.elasticache_replication_group_reader_endpoint_address
}

output "elasticache_replication_group_port" {
  value = module.redis.elasticache_replication_group_port
}
