locals {
  is_aurora           = startswith(var.engine, "aurora-")
  is_multi_az_cluster = !local.is_aurora
  is_serverless_v2    = local.is_aurora && var.serverlessv2_scaling_configuration != null

  port = coalesce(
    var.port,
    (var.engine == "aurora-postgresql" || var.engine == "postgres") ? 5432 : 3306,
  )

  db_subnet_group_name = var.create_db_subnet_group ? try(aws_db_subnet_group.this[0].name, null) : var.db_subnet_group_name

  db_cluster_parameter_group_name = var.create_db_cluster_parameter_group ? try(aws_rds_cluster_parameter_group.this[0].id, null) : var.db_cluster_parameter_group_name

  db_parameter_group_name = local.is_aurora && var.create_db_parameter_group ? try(aws_db_parameter_group.this[0].id, null) : var.db_parameter_group_name

  create_monitoring_role = var.monitoring_interval > 0 && var.create_monitoring_role
  monitoring_role_arn    = var.monitoring_interval > 0 ? (var.create_monitoring_role ? try(aws_iam_role.monitoring[0].arn, null) : var.monitoring_role_arn) : null
}
