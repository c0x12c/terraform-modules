data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_eks_node_group" "this" {
  # Required
  cluster_name  = var.cluster_name
  node_role_arn = aws_iam_role.this.arn
  subnet_ids    = var.subnet_ids

  scaling_config {
    min_size     = var.min_size
    max_size     = var.max_size
    desired_size = var.desired_size
  }

  # Optional
  node_group_name = var.name

  # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
  ami_type        = null
  release_version = null
  version         = var.node_group_version != null ? var.node_group_version : var.cluster_version

  capacity_type        = var.capacity_type
  disk_size            = var.disk_size # if using a custom LT, set disk size on custom LT or else it will error here
  force_update_version = var.force_update_version
  instance_types       = var.capacity_type == "CAPACITY_BLOCK" ? null : var.instance_types
  labels               = var.labels

  dynamic "remote_access" {
    for_each = length(var.remote_access) > 0 ? [var.remote_access] : []

    content {
      ec2_ssh_key               = try(remote_access.value.ec2_ssh_key, null)
      source_security_group_ids = try(remote_access.value.source_security_group_ids, [])
    }
  }

  dynamic "taint" {
    for_each = var.taints != null ? var.taints : []

    content {
      key    = taint.value.key
      value  = try(taint.value.value, null)
      effect = taint.value.effect
    }
  }

  dynamic "update_config" {
    for_each = length(var.update_config) > 0 ? [var.update_config] : []

    content {
      max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
      max_unavailable            = try(update_config.value.max_unavailable, null)
    }
  }

  dynamic "node_repair_config" {
    for_each = var.node_repair_config != null ? [var.node_repair_config] : []

    content {
      enabled = node_repair_config.value.enabled
    }
  }

  tags = merge(
    { "kubernetes.io/cluster/${var.cluster_name}" = "owned" },
    var.tags,
    { Name = var.name }
  )
}

