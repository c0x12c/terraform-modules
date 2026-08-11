locals {
  bucket = var.bucket_name != null ? aws_s3_bucket.without_prefix[0] : aws_s3_bucket.with_prefix[0]

  # Merge the deprecated single-statement variable with the new list variable so both are supported.
  custom_bucket_policies = concat(
    var.custom_bucket_policy != null ? [var.custom_bucket_policy] : [],
    var.custom_bucket_policies != null ? var.custom_bucket_policies : [],
  )
}

data "aws_caller_identity" "current" {}

/*
aws_s3_bucket main creates an S3 bucket with a specified name, adding environment tags for easier management.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
*/
resource "aws_s3_bucket" "with_prefix" {
  count               = var.bucket_name == null ? 1 : 0
  bucket_prefix       = var.bucket_prefix
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
}

resource "aws_s3_bucket" "without_prefix" {
  count               = var.bucket_name != null ? 1 : 0
  bucket              = var.bucket_name
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
}

/*
aws_s3_bucket_ownership_controls main configures ownership settings for the S3 bucket, preferring ownership by the bucket owner.
This ensures that uploaded objects are owned by the bucket account for consistent permissions.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
*/
resource "aws_s3_bucket_ownership_controls" "this" {
  count  = var.object_ownership != null ? 1 : 0
  bucket = local.bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}

/*
aws_s3_bucket_cors_configuration main sets up CORS policies for the S3 bucket, allowing specified HTTP methods and origins.
Defines allowed headers and a maximum age for caching responses from S3.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration
*/
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = var.enabled_cors ? 1 : 0
  bucket = local.bucket.id

  dynamic "cors_rule" {
    for_each = [var.cors_configuration]
    content {
      allowed_headers = try(cors_rule.value.allowed_headers, [])
      expose_headers  = try(cors_rule.value.expose_headers, [])
      allowed_methods = try(cors_rule.value.allowed_methods, [])
      allowed_origins = try(cors_rule.value.allowed_origins, [])
      max_age_seconds = try(cors_rule.value.max_age_seconds, 3600)
    }
  }
}

/*
aws_s3_bucket_public_access_block block_public_access enforces public access restrictions on the S3 bucket.
It blocks public policies and restricts public bucket access while allowing public ACLs as configured.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
*/
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = local.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

/*
aws_iam_policy_document generates an IAM policy document granting public access to S3 bucket objects.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
*/
data "aws_iam_policy_document" "this" {
  count = var.create_bucket_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.enabled_public_policy ? [1] : []
    content {
      sid       = "PublicReadGetObject"
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${local.bucket.arn}/*"]

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
    }
  }

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
        local.bucket.arn,
        "${local.bucket.arn}/*",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.access_logs_bucket_arn != null ? [var.access_logs_bucket_arn] : []

    content {
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["logging.s3.amazonaws.com"]
      }

      actions   = ["s3:PutObject"]
      resources = toset(["${var.access_logs_bucket_arn}/*"])

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = local.bucket.arn
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }

  dynamic "statement" {
    for_each = local.custom_bucket_policies
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = coalesce(statement.value.resources, [local.bucket.arn, "${local.bucket.arn}/*"])

      dynamic "principals" {
        for_each = statement.value.principals != null ? [statement.value.principals] : []
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.conditions != null ? statement.value.conditions : []
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

/*
aws_s3_bucket_policy attaches a policy to the S3 bucket, enabling the public access to bucket objects.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
*/
resource "aws_s3_bucket_policy" "this" {
  count  = var.create_bucket_policy ? 1 : 0
  bucket = local.bucket.id
  policy = data.aws_iam_policy_document.this.0.json
}

/*
aws_s3_bucket_versioning sets versioning status on the S3 bucket.
Versioning is disabled by default, meaning previous versions of files won't be retained.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
*/
resource "aws_s3_bucket_versioning" "this" {
  bucket = local.bucket.id
  versioning_configuration {
    status = var.versioning_status
  }

  lifecycle {
    # This must live on a non-counted resource; count = 0 would skip the check on the object-lock resource.
    precondition {
      condition     = var.object_lock_default_retention == null || var.object_lock_enabled
      error_message = "object_lock_default_retention requires object_lock_enabled = true; otherwise the retention rule is silently ignored."
    }
  }
}

/*
aws_s3_bucket_server_side_encryption_configuration configures bucket default server-side encryption without creating a KMS key.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
*/
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.server_side_encryption != null ? 1 : 0
  bucket = local.bucket.id

  rule {
    bucket_key_enabled = try(var.server_side_encryption.bucket_key_enabled, true)

    apply_server_side_encryption_by_default {
      kms_master_key_id = try(var.server_side_encryption.kms_master_key_id, null)
      sse_algorithm     = var.server_side_encryption.sse_algorithm
    }
  }
}

/*
aws_s3_bucket_object_lock_configuration configures S3 Object Lock retention defaults for newly created buckets.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration
*/
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count               = var.object_lock_enabled ? 1 : 0
  bucket              = local.bucket.id
  object_lock_enabled = "Enabled"

  depends_on = [
    aws_s3_bucket_versioning.this,
  ]

  dynamic "rule" {
    for_each = var.object_lock_default_retention != null ? [var.object_lock_default_retention] : []

    content {
      default_retention {
        mode  = rule.value.mode
        days  = try(rule.value.days, null)
        years = try(rule.value.years, null)
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.versioning_status == "Enabled"
      error_message = "object_lock_enabled requires versioning_status to be Enabled."
    }
  }
}

/**
aws_s3_bucket_acl provides an S3 bucket ACL resource.
NOTE:
- terraform destroy does not delete the S3 Bucket ACL but does remove the resource from Terraform state.
- This resource cannot be used with S3 directory buckets.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
 */
resource "aws_s3_bucket_acl" "this" {
  count = var.acl == "public-read" ? 1 : 0
  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]

  bucket = local.bucket.id
  acl    = var.acl
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
 */
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.s3_lifecycle_rules != null ? 1 : 0

  bucket = local.bucket.id

  dynamic "rule" {
    for_each = var.s3_lifecycle_rules != null ? var.s3_lifecycle_rules : []

    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.filter_prefix
      }

      transition {
        days          = rule.value.transition_days
        storage_class = rule.value.storage_class
      }

      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}
