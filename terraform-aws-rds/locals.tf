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

  # Gated on the ARN existing because RDS creates the managed secret while enabling managed
  # credentials: on the run that first enables them `secret_id = null` is a hard plan error
  # that aborts the whole root, not just this read. Cost of the gate is that `count` then
  # depends on the ARN, which is unknown during a create, so a greenfield create fails with
  # "Invalid count argument". Enable managed credentials out of band first - see README.
  read_managed_secret = (
    var.manage_master_user_password &&
    var.expose_managed_master_password &&
    local.managed_secret_arn != null
  )

  # Static gate, deliberately unlike read_managed_secret: `count` must be known at plan time
  # and the ARN is unknown during a create, so gating on it would block greenfield entirely.
  # A resource argument accepts an unknown value, so the ARN itself passes through fine.
  manage_master_secret_rotation = var.manage_master_user_password && (
    var.master_user_secret_rotation_days != null ||
    var.master_user_secret_rotation_schedule != null
  )
}
