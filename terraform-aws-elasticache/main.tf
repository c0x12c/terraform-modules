/**
`random_string` generates a random permutation of alphanumeric characters and optionally special characters.
https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
 */
resource "random_string" "this" {
  count            = var.transit_encryption_enabled ? 1 : 0
  length           = 32
  special          = true
  override_special = "!&#$^<>-"
}

/*
aws_elasticache_subnet_group creates a subnet group for Amazon ElastiCache.
This subnet group defines the VPC subnets where cache nodes will be deployed, ensuring they are isolated within specific subnets.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group
*/
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.cluster_name}-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_parameter_group" "this" {
  count       = var.custom_redis_parameters == null ? 0 : 1
  name        = replace("${var.cluster_name}-${var.engine}${local.major_version}", "_", "-")
  family      = local.engine_family
  description = "Custom redis parameter group"

  dynamic "parameter" {
    for_each = var.custom_redis_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

/*
aws_elasticache_replication_group provisions an Amazon ElastiCache replication group for a Redis cluster.
It defines configuration settings like instance type, engine version, availability, and failover behavior.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group
*/
resource "aws_elasticache_replication_group" "this" {
  depends_on = [aws_elasticache_subnet_group.this]

  replication_group_id = var.cluster_name
  description          = var.cluster_mode_enabled ? "${var.cluster_name} redis cluster" : "${var.cluster_name} redis (standalone)"
  # Multi-AZ / automatic failover require >= 1 replica. In standalone mode with no
  # replicas (single node) AWS rejects them as true, so force false in that case.
  multi_az_enabled = (var.cluster_mode_enabled || var.replicas_per_node_group > 0) ? var.multi_az_enabled : false
  node_type        = var.node_type
  # Cluster Mode Enabled uses num_node_groups/replicas_per_node_group (sharded).
  # Cluster Mode Disabled (standalone) uses num_cache_clusters = primary + replicas.
  num_node_groups         = var.cluster_mode_enabled ? var.cache_node_count : null
  replicas_per_node_group = var.cluster_mode_enabled ? var.replicas_per_node_group : null
  num_cache_clusters      = var.cluster_mode_enabled ? null : 1 + var.replicas_per_node_group

  parameter_group_name = local.parameter_group_name
  engine               = var.engine
  engine_version       = var.engine_version
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids = [
    var.security_group_allow_all_within_vpc_id
  ]

  apply_immediately          = var.apply_immediately
  snapshot_window            = var.snapshot_window
  automatic_failover_enabled = (var.cluster_mode_enabled || var.replicas_per_node_group > 0) ? var.automatic_failover_enabled : false

  at_rest_encryption_enabled = var.at_rest_encryption_enabled

  # The following blocks specified only if (var.transit_encryption_enabled == true)
  transit_encryption_enabled = var.transit_encryption_enabled
  transit_encryption_mode    = var.transit_encryption_mode # make sure you update this when enabled transit encryption
  auth_token                 = var.transit_encryption_enabled ? random_string.this[0].result : null
  auth_token_update_strategy = "ROTATE"
}
