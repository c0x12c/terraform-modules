resource "random_password" "this" {
  count = !var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  # keepers is ForceNew, so unset -> any value replaces the password. Null unless the caller
  # opts in, otherwise adopting this module version rotates every existing database at once.
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
  count = local.read_managed_secret ? 1 : 0

  secret_id = local.managed_secret_arn
}

resource "aws_secretsmanager_secret_rotation" "managed" {
  # Errors when manage_master_user_password is enabled in Terraform without the out-of-band
  # step first, since the ARN is then known-null. The README rules that path out.
  count = local.manage_master_secret_rotation ? 1 : 0

  secret_id = local.managed_secret_arn

  # The provider defaults this to true, so omitting it rotates every managed master password
  # on the run that adopts these inputs. Rotate out of band if you want one immediately.
  rotate_immediately = false

  rotation_rules {
    automatically_after_days = var.master_user_secret_rotation_days
    schedule_expression      = var.master_user_secret_rotation_schedule
    duration                 = var.master_user_secret_rotation_duration
  }

  # No rotation_lambda_arn: an RDS-owned secret (OwningService: rds) is rotated by RDS itself.
}
