data "aws_iam_policy_document" "this_policy" {
  count = var.enabled_public_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      local.bucket.arn,
      "${local.bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "readonly_policy" {
  count = var.enabled_read_only_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
    ]
    resources = [
      local.bucket.arn,
      "${local.bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "read_write_policy" {
  count = var.enabled_read_write_policy ? 1 : 0
  statement {
    effect  = "Allow"
    actions = var.read_write_actions
    resources = [
      local.bucket.arn,
      "${local.bucket.arn}/*"
    ]
  }
}

/*
aws_iam_policy main creates an IAM policy for write access to the specified S3 bucket.
The policy allows overriding object ownership to the bucket owner, uploading objects, and setting object ACLs.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
*/
resource "aws_iam_policy" "this" {
  count       = var.enabled_public_policy ? 1 : 0
  name        = "${var.public_policy_name_prefix}-${local.bucket.bucket}"
  description = var.public_policy_description

  policy = data.aws_iam_policy_document.this_policy.0.json
}

/*
aws_iam_policy readonly creates an IAM policy for read-only access to the specified S3 bucket.
The policy allows listing, getting objects, and viewing object ACLs within the bucket.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
*/
resource "aws_iam_policy" "readonly" {
  count       = var.enabled_read_only_policy ? 1 : 0
  name        = var.custom_readonly_policy_name != null ? var.custom_readonly_policy_name : "${var.readonly_policy_name_prefix}-${local.bucket.bucket}"
  description = var.readonly_policy_description

  policy = data.aws_iam_policy_document.readonly_policy.0.json
}

/*
aws_iam_policy read_write_policy creates an IAM policy for read_write_policy access to the specified S3 bucket.
The policy allows listing, getting objects, and viewing object ACLs within the bucket.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
*/
resource "aws_iam_policy" "read_write" {
  count       = var.enabled_read_write_policy ? 1 : 0
  name        = var.custom_read_write_policy_name != null ? var.custom_read_write_policy_name : "${var.read_write_policy_name_prefix}-${local.bucket.bucket}"
  description = var.read_write_policy_description
  policy      = data.aws_iam_policy_document.read_write_policy.0.json
}
