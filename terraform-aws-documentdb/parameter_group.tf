resource "aws_docdb_cluster_parameter_group" "this" {
  count = var.create_db_cluster_parameter_group ? 1 : 0

  name_prefix = "${var.name}-"
  family      = var.db_cluster_parameter_group_family
  description = "Cluster parameter group for ${var.name} DocumentDB cluster"

  parameter {
    name  = "tls"
    value = var.tls_enabled ? "enabled" : "disabled"
  }

  dynamic "parameter" {
    for_each = var.db_cluster_parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
