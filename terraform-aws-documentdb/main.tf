resource "random_id" "snapshot_suffix" {
  byte_length = 4
  keepers = {
    cluster = var.name
  }
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier = var.name

  engine         = "docdb"
  engine_version = var.engine_version

  master_username = var.master_username
  master_password = local.master_password
  port            = local.port

  db_subnet_group_name            = local.db_subnet_group_name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = local.cluster_parameter_group_name

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-${random_id.snapshot_suffix.hex}"
  deletion_protection       = var.deletion_protection

  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = var.tags

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
    ]
  }
}

resource "aws_docdb_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.name}-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class

  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  preferred_maintenance_window = var.preferred_maintenance_window

  tags = var.tags
}
