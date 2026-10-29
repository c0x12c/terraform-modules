resource "aws_s3_bucket" "tiered" {
  count = var.tiered_storage.enabled && var.tiered_storage.bucket_name == null ? 1 : 0

  bucket_prefix = "${lower(substr(local.aws_name, 0, 29))}-tiered-"
  force_destroy = var.tiered_storage.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "tiered" {
  count = length(aws_s3_bucket.tiered)

  bucket                  = aws_s3_bucket.tiered[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tiered" {
  count = length(aws_s3_bucket.tiered)

  bucket = aws_s3_bucket.tiered[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tiered" {
  count = length(aws_s3_bucket.tiered)

  bucket = aws_s3_bucket.tiered[0].id
  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
