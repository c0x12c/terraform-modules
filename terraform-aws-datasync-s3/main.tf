resource "aws_datasync_location_s3" "source" {
  count = local.create ? 1 : 0

  s3_bucket_arn    = var.source_bucket_arn
  subdirectory     = var.source_subdirectory
  s3_storage_class = var.source_storage_class

  s3_config {
    bucket_access_role_arn = aws_iam_role.this[0].arn
  }

  tags = merge(var.tags, { Name = "${var.name}-source" })

  # The role policy must land before DataSync validates bucket access.
  depends_on = [aws_iam_role_policy.this]
}

resource "aws_datasync_location_s3" "destination" {
  count = local.create ? 1 : 0

  s3_bucket_arn    = var.destination_bucket_arn
  subdirectory     = var.destination_subdirectory
  s3_storage_class = var.destination_storage_class

  s3_config {
    bucket_access_role_arn = aws_iam_role.this[0].arn
  }

  tags = merge(var.tags, { Name = "${var.name}-destination" })

  depends_on = [aws_iam_role_policy.this]
}

resource "aws_datasync_task" "this" {
  count = local.create ? 1 : 0

  name                     = var.name
  source_location_arn      = aws_datasync_location_s3.source[0].arn
  destination_location_arn = aws_datasync_location_s3.destination[0].arn
  cloudwatch_log_group_arn = local.logging ? "${aws_cloudwatch_log_group.this[0].arn}:*" : null

  options {
    verify_mode            = var.task_options.verify_mode
    overwrite_mode         = var.task_options.overwrite_mode
    preserve_deleted_files = var.task_options.preserve_deleted_files
    preserve_devices       = var.task_options.preserve_devices
    posix_permissions      = var.task_options.posix_permissions
    uid                    = var.task_options.uid
    gid                    = var.task_options.gid
    atime                  = var.task_options.atime
    mtime                  = var.task_options.mtime
    transfer_mode          = var.task_options.transfer_mode
    object_tags            = var.task_options.object_tags
    log_level              = local.logging ? var.task_options.log_level : "OFF"
  }

  dynamic "excludes" {
    for_each = length(var.excluded_patterns) > 0 ? [1] : []
    content {
      filter_type = "SIMPLE_PATTERN"
      value       = join("|", var.excluded_patterns)
    }
  }

  dynamic "includes" {
    for_each = length(var.included_patterns) > 0 ? [1] : []
    content {
      filter_type = "SIMPLE_PATTERN"
      value       = join("|", var.included_patterns)
    }
  }

  dynamic "task_report_config" {
    for_each = var.enable_task_report ? [1] : []
    content {
      output_type  = var.task_report_output_type
      report_level = var.task_report_level

      s3_destination {
        bucket_access_role_arn = aws_iam_role.this[0].arn
        s3_bucket_arn          = var.destination_bucket_arn
        subdirectory           = var.task_report_subdirectory
      }
    }
  }

  dynamic "schedule" {
    for_each = local.has_schedule ? [1] : []
    content {
      schedule_expression = var.schedule_expression
    }
  }

  tags = var.tags

  depends_on = [aws_cloudwatch_log_resource_policy.this]
}
