resource "aws_db_subnet_group" "this" {
  count = var.create_db_subnet_group ? 1 : 0

  name        = coalesce(var.db_subnet_group_name, var.name)
  description = "Subnet group for ${var.name} cluster"
  subnet_ids  = var.subnets
  tags        = var.tags

  lifecycle {
    precondition {
      condition     = length(var.subnets) > 0
      error_message = "subnets must not be empty when create_db_subnet_group is true."
    }
  }
}

resource "random_id" "snapshot_suffix" {
  byte_length = 4
  keepers = {
    cluster = var.name
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.name

  engine         = var.engine
  engine_mode    = local.is_aurora ? var.engine_mode : null
  engine_version = var.engine_version

  database_name                 = var.database_name
  master_username               = var.master_username
  manage_master_user_password   = var.manage_master_user_password ? true : null
  master_user_secret_kms_key_id = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null

  port = local.port

  db_subnet_group_name            = local.db_subnet_group_name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = local.db_cluster_parameter_group_name

  # Multi-AZ DB cluster only
  allocated_storage         = local.is_multi_az_cluster ? var.allocated_storage : null
  db_cluster_instance_class = local.is_multi_az_cluster ? var.db_cluster_instance_class : null
  iops                      = local.is_multi_az_cluster ? var.iops : null
  storage_type              = var.storage_type

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-${random_id.snapshot_suffix.hex}"
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  deletion_protection       = var.deletion_protection

  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Multi-AZ DB cluster manages monitoring + Performance Insights at the cluster level.
  # Aurora handles them per-instance via aws_rds_cluster_instance.
  monitoring_interval = local.is_multi_az_cluster ? var.monitoring_interval : null
  monitoring_role_arn = local.is_multi_az_cluster ? local.monitoring_role_arn : null

  performance_insights_enabled          = local.is_multi_az_cluster ? var.performance_insights_enabled : null
  performance_insights_retention_period = local.is_multi_az_cluster && var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = local.is_multi_az_cluster && var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.is_serverless_v2 ? [var.serverlessv2_scaling_configuration] : []
    content {
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
    ]

    precondition {
      condition = local.is_aurora ? (
        var.allocated_storage == null && var.db_cluster_instance_class == null
        ) : (
        var.allocated_storage != null && var.db_cluster_instance_class != null && var.storage_type != null
      )
      error_message = "Aurora engines must omit allocated_storage and db_cluster_instance_class. Multi-AZ DB cluster engines (mysql/postgres) require allocated_storage, db_cluster_instance_class, and storage_type."
    }

    precondition {
      condition     = local.is_aurora || var.serverlessv2_scaling_configuration == null
      error_message = "serverlessv2_scaling_configuration is only valid for Aurora engines."
    }

    precondition {
      condition     = local.is_aurora || length(var.instances) == 0
      error_message = "instances map is only used for Aurora; Multi-AZ DB cluster manages its own 3 instances via the cluster resource."
    }
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }

  depends_on = [aws_iam_role_policy_attachment.monitoring]
}

resource "aws_rds_cluster_instance" "this" {
  for_each = local.is_aurora ? var.instances : {}

  identifier         = "${var.name}-${each.key}"
  cluster_identifier = aws_rds_cluster.this.id

  engine         = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version

  instance_class = local.is_serverless_v2 ? "db.serverless" : coalesce(each.value.instance_class, var.instance_class)

  availability_zone = each.value.availability_zone

  db_subnet_group_name    = local.db_subnet_group_name
  db_parameter_group_name = coalesce(each.value.db_parameter_group_name, local.db_parameter_group_name)

  publicly_accessible = coalesce(each.value.publicly_accessible, false)
  promotion_tier      = coalesce(each.value.promotion_tier, 0)

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = local.monitoring_role_arn

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}
