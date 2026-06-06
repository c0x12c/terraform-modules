locals {
  filesystem_name = var.efs_filesystem_name != null ? var.efs_filesystem_name : join("-", [var.name, var.environment, "eks", "efs"])
}

resource "aws_efs_file_system" "eks" {
  creation_token = local.filesystem_name

  performance_mode = var.filesystem_performance_mode
  throughput_mode  = var.filesystem_throughput_mode
  encrypted        = var.filesystem_encrypted

  dynamic "lifecycle_policy" {
    for_each = var.efs_lifecycle_policy
    content {
      transition_to_ia                    = lookup(lifecycle_policy.value, "transition_to_ia", null)
      transition_to_primary_storage_class = lookup(lifecycle_policy.value, "transition_to_primary_storage_class", null)
    }
  }

  tags = {
    Name = local.filesystem_name
  }
}

resource "aws_efs_backup_policy" "this" {
  file_system_id = aws_efs_file_system.eks.id

  backup_policy {
    status = var.efs_backup_policy_status
  }
}

resource "aws_efs_mount_target" "mount_target" {
  count          = length(var.private_subnet_ids)
  file_system_id = aws_efs_file_system.eks.id
  subnet_id      = var.private_subnet_ids[count.index]
  security_groups = [
    var.cluster_security_group_id
  ]
}

resource "kubernetes_storage_class" "this" {
  metadata {
    name = var.efs_storage_class_name
  }
  storage_provisioner    = "efs.csi.aws.com"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "777"
  }
}
