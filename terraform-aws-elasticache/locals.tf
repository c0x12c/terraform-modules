locals {
  major_version = split(".", var.engine_version)[0]
  # Parameter-group family follows the engine: redis7 / valkey8 (not always "redis").
  engine_family        = "${var.engine}${local.major_version}"
  parameter_group_name = var.custom_redis_parameters == null ? var.parameter_group_name : aws_elasticache_parameter_group.this[0].name
}
