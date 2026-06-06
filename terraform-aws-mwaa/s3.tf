# ---------------------------------------------------------------------------------------------------------------------
# MWAA S3 Bucket
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = var.source_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
