resource "aws_datasync_task" "this" {
  name                     = var.name
  source_location_arn      = local.source_location_arn
  destination_location_arn = local.destination_location_arn
  cloudwatch_log_group_arn = local.cloudwatch_log_group_arn

  dynamic "schedule" {
    for_each = var.schedule_expression != null ? [1] : []

    content {
      schedule_expression = var.schedule_expression
    }
  }

  dynamic "options" {
    for_each = var.options != null ? [var.options] : []

    content {
      atime                          = options.value.atime
      bytes_per_second               = options.value.bytes_per_second
      gid                            = options.value.gid
      log_level                      = options.value.log_level
      mtime                          = options.value.mtime
      object_tags                    = options.value.object_tags
      overwrite_mode                 = options.value.overwrite_mode
      posix_permissions              = options.value.posix_permissions
      preserve_deleted_files         = options.value.preserve_deleted_files
      preserve_devices               = options.value.preserve_devices
      security_descriptor_copy_flags = options.value.security_descriptor_copy_flags
      task_queueing                  = options.value.task_queueing
      transfer_mode                  = options.value.transfer_mode
      uid                            = options.value.uid
      verify_mode                    = options.value.verify_mode
    }
  }

  dynamic "includes" {
    for_each = length(var.include_patterns) > 0 ? [1] : []

    content {
      filter_type = "SIMPLE_PATTERN"
      value       = join("|", var.include_patterns)
    }
  }

  dynamic "excludes" {
    for_each = length(var.exclude_patterns) > 0 ? [1] : []

    content {
      filter_type = "SIMPLE_PATTERN"
      value       = join("|", var.exclude_patterns)
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = local.source_count == 1
      error_message = "Exactly one of source_s3, source_object_storage, or source_location_arn must be set."
    }

    precondition {
      condition     = local.destination_count == 1
      error_message = "Exactly one of destination_s3, destination_object_storage, or destination_location_arn must be set."
    }

    precondition {
      condition     = !(var.create_cloudwatch_log_group && var.cloudwatch_log_group_arn != null)
      error_message = "Set only one of create_cloudwatch_log_group or cloudwatch_log_group_arn."
    }
  }
}
