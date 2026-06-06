resource "aws_s3_bucket_website_configuration" "main" {
  count = var.s3_redirect_domain != null ? 1 : 0

  bucket = var.s3_bucket_id

  redirect_all_requests_to {
    host_name = var.s3_redirect_domain
  }
}
