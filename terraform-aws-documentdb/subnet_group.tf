resource "aws_docdb_subnet_group" "this" {
  count = var.create_db_subnet_group ? 1 : 0

  name        = coalesce(var.db_subnet_group_name, var.name)
  description = "Subnet group for ${var.name} DocumentDB cluster"
  subnet_ids  = var.subnets
  tags        = var.tags

  lifecycle {
    precondition {
      condition     = length(var.subnets) > 0
      error_message = "subnets must not be empty when create_db_subnet_group is true."
    }
  }
}
