resource "random_password" "this" {
  count = var.master_password == null ? 1 : 0

  length  = var.password_length
  special = false
}

resource "aws_secretsmanager_secret" "this" {
  count = var.create_secret ? 1 : 0

  name                    = coalesce(var.secret_name, "${var.name}-connection")
  description             = "Connection details for the ${var.name} DocumentDB cluster"
  recovery_window_in_days = var.secret_recovery_window_in_days
  kms_key_id              = var.secret_kms_key_id
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.create_secret ? 1 : 0

  secret_id = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode({
    host     = aws_docdb_cluster.this.endpoint
    port     = local.port
    username = var.master_username
    password = local.master_password
    database = local.database_path
    tls      = var.tls_enabled
    uri      = local.connection_uri
  })
}
