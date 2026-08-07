locals {
  engine_version_major = var.engine == "postgres" ? tostring(parseint(split(".", var.engine_version)[0], 10)) : var.engine_version
  identifier           = replace(var.db_name, "_", "-")
  max_workers = {
    "db.m5.4xlarge"  = 16
    "db.m5.12xlarge" = 48
    "db.m5.24xlarge" = 96
    "db.r5.4xlarge"  = 16
    "db.r5.12xlarge" = 48
    "db.r5.24xlarge" = 96
  }
  db_subnet_group_description  = "${var.db_name} db subnet group"
  db_subnet_group_name         = var.db_subnet_group_name != null ? var.db_subnet_group_name : "${var.db_name}-subnet"
  default_backup_retention     = var.backup_retention_day
  db_final_snapshot_identifier = "${local.identifier}-${formatdate("HH-mmaa", timestamp())}"

  db_password = var.manage_master_user_password ? null : (
    var.use_secret_manager ? aws_secretsmanager_secret_version.this[0].secret_string : random_password.this[0].result
  )

  managed_secret_arn = module.main_db_instance.master_user_secret_arn

  # count must be known at plan time, so neither gate may reference the managed secret ARN.
  #
  # The ARN is unknown while an instance is being created. Gating on it failed every
  # greenfield create with "Invalid count argument".
  #
  # Tradeoff: on an existing instance the ARN is null until managed credentials are enabled
  # out of band, and a null secret_id aborts the whole root's plan. See README.
  read_managed_secret = var.manage_master_user_password && var.expose_managed_master_password

  manage_master_secret_rotation = var.manage_master_user_password && (
    var.master_user_secret_rotation_days != null ||
    var.master_user_secret_rotation_schedule != null
  )

  notify_master_secret_rotation_failure = (
    local.manage_master_secret_rotation &&
    var.master_user_secret_rotation_failure_sns_topic_arn != null
  )
}
