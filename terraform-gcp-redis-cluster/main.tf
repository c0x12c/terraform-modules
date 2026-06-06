/**
`google_redis_cluster` provisions a redis cluster.
https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/redis_cluster
 */
resource "google_redis_cluster" "this" {
  provider = google-beta

  name                    = "redis-cluster-${var.name}"
  region                  = var.region
  replica_count           = var.replica_count
  shard_count             = var.shard_count
  authorization_mode      = var.authorization_mode
  transit_encryption_mode = var.transit_encryption_mode
  node_type               = var.node_type

  zone_distribution_config {
    mode = "MULTI_ZONE"
  }

  psc_configs {
    network = var.vpc_id
  }
}
