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

  # Both gates below feed a `count`, so they must not reference the managed secret ARN.
  # `count` has to be known at plan time. The ARN is unknown while an instance is being
  # created, and gating on it fails every greenfield create with "Invalid count argument".
  #
  # The tradeoff: the ARN is null until RDS creates the secret, and `secret_id = null` is a
  # hard plan error that takes down the whole root. That only happens if you enable
  # manage_master_user_password in Terraform without enabling it on the instance first.
  # The README documents that out-of-band step; skipping it fails loudly rather than
  # silently writing an empty password.
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
