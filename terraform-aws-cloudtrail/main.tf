resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.name}-"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_status
  }
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.disabled_s3_http_access ? [1] : []

    content {
      actions = [
        "s3:*",
      ]

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }

      effect = "Deny"

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      resources = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*",
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.this.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

locals {
  cloud_watch_logs_group_arn = var.cloud_watch_logs_group_arn != null ? var.cloud_watch_logs_group_arn : (
    var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.this[0].arn : null
  )
  cloud_watch_logs_role_arn = var.cloud_watch_logs_role_arn != null ? var.cloud_watch_logs_role_arn : (
    var.create_cloudwatch_log_group ? aws_iam_role.cloudwatch[0].arn : null
  )
}

resource "aws_cloudtrail" "this" {
  name                          = var.name
  enable_logging                = var.enable_logging
  s3_bucket_name                = aws_s3_bucket.this.id
  enable_log_file_validation    = var.enable_log_file_validation
  sns_topic_name                = var.sns_topic_name
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = local.cloud_watch_logs_role_arn
  # Apply the log-stream wildcard only when there is a group ARN to apply it to.
  #
  # The default is no CloudWatch integration (create_cloudwatch_log_group = false), which leaves
  # this local null, and interpolating null fails with "Invalid template interpolation value".
  #
  # terraform validate does not evaluate expressions, so module CI cannot catch this class.
  cloud_watch_logs_group_arn = local.cloud_watch_logs_group_arn != null ? "${local.cloud_watch_logs_group_arn}:*" : null
  kms_key_id                 = var.kms_key_arn
  is_organization_trail      = var.is_organization_trail
  s3_key_prefix              = var.s3_key_prefix

  dynamic "insight_selector" {
    for_each = var.insight_selector
    content {
      insight_type = insight_selector.value.insight_type
    }
  }

  dynamic "event_selector" {
    for_each = var.event_selector
    content {
      include_management_events = lookup(event_selector.value, "include_management_events", null)
      read_write_type           = lookup(event_selector.value, "read_write_type", null)

      dynamic "data_resource" {
        for_each = lookup(event_selector.value, "data_resource", [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_policy.this]
}

# Zero rules is not a valid lifecycle configuration, so a consumer on the default gets no resource
# at all rather than a plan-time error.
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket                                 = aws_s3_bucket.this.id
  transition_default_minimum_object_size = var.transition_default_minimum_object_size

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [rule.value.expiration_days] : []
        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [rule.value.noncurrent_version_expiration_days] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_mpu_days != null ? [rule.value.abort_incomplete_mpu_days] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }
    }
  }

  # Versioning must settle before rules that act on noncurrent versions are attached.
  depends_on = [aws_s3_bucket_versioning.this]
}
