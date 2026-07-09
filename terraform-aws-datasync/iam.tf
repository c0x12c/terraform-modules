data "aws_iam_policy_document" "s3_assume" {
  count = length(local.s3_role_targets) > 0 ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_access" {
  for_each = local.s3_role_targets

  name_prefix        = substr("${var.name}-${each.key}-", 0, 32)
  description        = "DataSync S3 access role for ${var.name} (${each.key})"
  assume_role_policy = data.aws_iam_policy_document.s3_assume[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "s3_access" {
  for_each = local.s3_role_targets

  statement {
    sid       = "BucketLevel"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"]
    resources = [each.value]
  }

  statement {
    sid = "ObjectLevel"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectTagging",
    ]
    resources = ["${each.value}/*"]
  }
}

resource "aws_iam_role_policy" "s3_access" {
  for_each = local.s3_role_targets

  name_prefix = "s3-access-"
  role        = aws_iam_role.s3_access[each.key].id
  policy      = data.aws_iam_policy_document.s3_access[each.key].json
}
