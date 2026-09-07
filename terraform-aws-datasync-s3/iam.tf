data "aws_iam_policy_document" "assume" {
  count = local.create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }
  }
}

# The task runs in the destination account: read the source bucket, write the
# destination bucket. A cross-account source also needs a bucket policy there
# granting this role (see README).
data "aws_iam_policy_document" "s3" {
  count = local.create ? 1 : 0

  statement {
    sid    = "SourceBucketRead"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [var.source_bucket_arn]
  }

  statement {
    sid    = "SourceObjectRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:ListMultipartUploadParts",
    ]
    resources = ["${var.source_bucket_arn}/*"]
  }

  statement {
    sid    = "DestinationBucketWrite"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [var.destination_bucket_arn]
  }

  statement {
    sid    = "DestinationObjectWrite"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectTagging",
    ]
    resources = ["${var.destination_bucket_arn}/*"]
  }

  # SSE-KMS buckets reject the transfer without key access.
  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [1] : []
    content {
      sid    = "BucketKmsAccess"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:ReEncrypt*",
      ]
      resources = var.kms_key_arns
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create ? 1 : 0

  name                 = local.iam_role_name
  assume_role_policy   = data.aws_iam_policy_document.assume[0].json
  permissions_boundary = var.iam_role_permissions_boundary
  tags                 = var.tags
}

resource "aws_iam_role_policy" "this" {
  count = local.create ? 1 : 0

  name   = "${local.iam_role_name}-s3"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.s3[0].json
}
