provider "aws" {
  region = "us-east-1"
}

module "s3_datasync" {
  source = "../../"

  name = "example-transfer"

  source_bucket_arn      = "arn:aws:s3:::example-source-bucket"
  destination_bucket_arn = "arn:aws:s3:::example-destination-bucket"

  # Hourly catch-up while the cutover is in flight; drop it for on-demand runs.
  schedule_expression = "cron(0 * * * ? *)"

  tags = {
    Environment = "dev"
  }
}
