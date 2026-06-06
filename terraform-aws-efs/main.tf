locals {
  filesystem_name = var.name
}

resource "aws_efs_file_system" "this" {
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
  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = var.efs_backup_policy_status
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.name}-efs-sg"
  description = "Allow NFS access to EFS"
  vpc_id      = var.vpc_id

  # Allow inbound NFS traffic from allowed sources (e.g., instances in a specific security group)
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = [data.aws_vpc.this.cidr_block]
    security_groups = var.allowed_security_group_ids
  }

  # Allow all outbound traffic (default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-efs-sg"
  }
}

resource "aws_efs_mount_target" "mount_target" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = aws_security_group.efs_sg.*.id
}

resource "aws_efs_access_point" "this" {
  for_each = var.efs_access_points

  file_system_id = aws_efs_file_system.this.id

  posix_user {
    gid = each.value.posix_user.gid
    uid = each.value.posix_user.uid
  }

  root_directory {
    path = each.value.root_directory.path

    creation_info {
      owner_gid   = each.value.root_directory.creation_info.owner_gid
      owner_uid   = each.value.root_directory.creation_info.owner_uid
      permissions = each.value.root_directory.creation_info.permissions
    }
  }

  tags = {
    Name = each.key
  }
}

