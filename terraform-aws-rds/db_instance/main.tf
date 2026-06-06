resource "aws_db_instance" "this" {
  identifier                   = var.identifier
  instance_class               = var.instance_class
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  engine                       = var.engine
  engine_version               = var.engine_version
  username                     = var.username
  password                     = var.password
  db_subnet_group_name         = var.db_subnet_group_name
  vpc_security_group_ids       = var.vpc_security_group_ids
  db_name                      = var.db_name
  port                         = var.port
  backup_retention_period      = var.backup_retention_period
  storage_type                 = var.storage_type
  storage_encrypted            = var.storage_encrypted
  replicate_source_db          = var.replicate_source_db
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = var.apply_immediately
  monitoring_interval          = var.monitoring_interval
  performance_insights_enabled = var.performance_insights_enabled
  parameter_group_name         = var.parameter_group_name
  publicly_accessible          = var.publicly_accessible
  final_snapshot_identifier    = var.final_snapshot_identifier
  skip_final_snapshot          = var.skip_final_snapshot
  copy_tags_to_snapshot        = var.copy_tags_to_snapshot
  multi_az                     = var.multi_az
  deletion_protection          = var.deletion_protection

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  enabled_cloudwatch_logs_exports = var.cloudwatch_exported_log_types

  lifecycle {
    ignore_changes = [
      storage_type,
      iops,
      max_allocated_storage,
      final_snapshot_identifier
    ]
  }
  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}
