module "s3_bucket" {
  source = "../../"

  bucket_name         = "example-bucket"
  bucket_prefix       = null
  versioning_status   = "Enabled"
  object_lock_enabled = true
  object_lock_default_retention = {
    mode = "GOVERNANCE"
    days = 30
  }
  server_side_encryption = {
    sse_algorithm     = "aws:kms"
    kms_master_key_id = "arn:aws:kms:us-east-1:111122223333:key/12345678-1234-1234-1234-123456789012"
  }

  enabled_cors = true
  cors_configuration = {
    allowed_origins = ["example.com"]
    allowed_methods = ["GET"]
  }

  enabled_iam_policy = true
}
