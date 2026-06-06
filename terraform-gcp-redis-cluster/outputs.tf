output "host" {
  description = "The connection endpoint for the Redis cluster, combining the address and port of the first discovery endpoint."
  value       = "${google_redis_cluster.this.discovery_endpoints[0].address}:${google_redis_cluster.this.discovery_endpoints[0].port}"
}
