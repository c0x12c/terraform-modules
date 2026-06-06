data "aws_s3_bucket" "this" {
  count = var.enabled_create_s3 ? 0 : 1

  bucket = var.existing_s3_bucket_name != null ? var.existing_s3_bucket_name : var.name
}

module "s3" {
  source  = "c0x12c/s3/aws"
  version = "1.1.0"

  count = var.enabled_create_s3 ? 1 : 0

  bucket_prefix     = var.bucket_prefix != null ? var.bucket_prefix : var.name
  force_destroy     = true
  versioning_status = var.versioning_status

  # bucket policy
  create_bucket_policy = true
  custom_bucket_policy = {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.s3[0].s3_bucket_arn}/*"]

    principals = {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    conditions = [{
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront.cloudfront_distribution_arn]
    }]
  }
  access_logs_bucket_arn = var.access_logs_bucket_arn

  # permission
  enabled_read_only_policy  = var.enabled_read_only_policy
  enabled_read_write_policy = var.enabled_read_write_policy

  custom_readonly_policy_name = var.s3_custom_readonly_policy_name
  readonly_policy_description = var.s3_readonly_policy_description

  custom_read_write_policy_name = var.s3_custom_read_write_policy_name
  read_write_policy_description = var.s3_read_write_policy_description
}
