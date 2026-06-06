module "s3_bucket" {
  source = "../../"

  bucket_name   = "example-bucket"
  bucket_prefix = null


  enabled_cors = true
  cors_configuration = {
    allowed_origins = ["example.com"]
    allowed_methods = ["GET"]
  }

  enabled_iam_policy = true
}
