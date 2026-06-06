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
  cloud_watch_logs_group_arn    = "${local.cloud_watch_logs_group_arn}:*" # CloudTrail requires the Log Stream wildcard
  kms_key_id                    = var.kms_key_arn
  is_organization_trail         = var.is_organization_trail
  s3_key_prefix                 = var.s3_key_prefix

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
