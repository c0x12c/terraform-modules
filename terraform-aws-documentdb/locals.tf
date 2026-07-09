locals {
  port = 27017

  db_subnet_group_name = var.create_db_subnet_group ? try(aws_docdb_subnet_group.this[0].name, null) : var.db_subnet_group_name

  cluster_parameter_group_name = var.create_db_cluster_parameter_group ? try(aws_docdb_cluster_parameter_group.this[0].id, null) : var.db_cluster_parameter_group_name

  master_password = coalesce(var.master_password, try(random_password.this[0].result, null))

  database_path = var.database_name == null ? "" : var.database_name

  connection_uri = format(
    "mongodb://%s:%s@%s:%d/%s?tls=%s&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false",
    urlencode(var.master_username),
    urlencode(local.master_password),
    aws_docdb_cluster.this.endpoint,
    local.port,
    local.database_path,
    var.tls_enabled ? "true" : "false",
  )
}
