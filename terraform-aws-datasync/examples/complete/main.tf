module "datasync" {
  source = "../../"

  name = "example-gcs-to-s3"

  source_object_storage = {
    server_hostname = "storage.googleapis.com"
    bucket_name     = "example-source-bucket"
    agent_arns      = ["arn:aws:datasync:us-west-2:111122223333:agent/agent-0123456789abcdef0"]
    access_key      = "EXAMPLE_HMAC_ACCESS_KEY"
    secret_key      = "EXAMPLE_HMAC_SECRET_KEY"
  }

  destination_s3 = {
    s3_bucket_arn = "arn:aws:s3:::example-destination-bucket"
    subdirectory  = "/incoming"
  }

  schedule_expression = "rate(1 day)"
  exclude_patterns    = ["*/_tmp"]

  create_cloudwatch_log_group = true

  tags = {
    Environment = "dev"
  }
}
