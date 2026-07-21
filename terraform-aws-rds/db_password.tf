resource "random_password" "this" {
  count = !var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

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
  count = var.manage_master_user_password && var.expose_managed_master_password ? 1 : 0

  secret_id = module.main_db_instance.master_user_secret_arn
}
