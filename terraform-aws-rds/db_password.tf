resource "random_password" "this" {
  count = !var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  # Rotation handle. Kept null unless the caller opts in, because keepers is
  # ForceNew and going from unset to any value replaces the password - so an
  # unconditional keepers block would rotate every existing database the moment
  # this module version is adopted. Null preserves the current value; changing it
  # to a new value is what deliberately rotates.
  keepers = var.db_password_rotation_id == null ? null : {
    rotation = var.db_password_rotation_id
  }

  length  = var.password_length
  special = false
}

data "aws_secretsmanager_random_password" "this" {
  count = var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  password_length     = var.password_length
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret" "this" {
  count = var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  name = var.secret_manager_db_password_name
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = data.aws_secretsmanager_random_password.this[0].id

  // ignore any updates to the initial values above done after creation.
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}

data "aws_secretsmanager_secret_version" "managed" {
  # Also gated on the ARN actually existing. RDS creates the managed secret as part of
  # enabling manage_master_user_password, so on the apply that FIRST enables it the ARN is
  # still null and this data source would try to read a secret that does not exist yet -
  # `secret_id = null` is a hard plan error ("Missing required argument"), which blocked the
  # whole plan rather than just this read. Gating on non-null degrades that to an empty
  # result for one apply instead.
  #
  # Consequence: on that first apply db_password resolves to null, so a caller feeding it
  # into a Kubernetes Secret or similar must enable managed credentials on the instance
  # BEFORE turning this on (e.g. aws rds modify-db-instance --manage-master-user-password),
  # so the ARN is present in state by the time this is read. See README.
  count = (
    var.manage_master_user_password &&
    var.expose_managed_master_password &&
    module.main_db_instance.master_user_secret_arn != null
  ) ? 1 : 0

  secret_id = module.main_db_instance.master_user_secret_arn
}
