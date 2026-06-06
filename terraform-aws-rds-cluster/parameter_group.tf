resource "aws_rds_cluster_parameter_group" "this" {
  count = var.create_db_cluster_parameter_group ? 1 : 0

  name        = "${var.name}-cluster"
  family      = var.db_cluster_parameter_group_family
  description = "Cluster parameter group for ${var.name}"

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

    precondition {
      condition     = var.db_cluster_parameter_group_family != null
      error_message = "db_cluster_parameter_group_family is required when create_db_cluster_parameter_group is true."
    }
  }
}

resource "aws_db_parameter_group" "this" {
  count = local.is_aurora && var.create_db_parameter_group ? 1 : 0

  name        = "${var.name}-instance"
  family      = coalesce(var.db_parameter_group_family, var.db_cluster_parameter_group_family)
  description = "Instance parameter group for ${var.name}"

  dynamic "parameter" {
    for_each = var.db_parameter_group_parameters
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
