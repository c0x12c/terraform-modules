module "static_website" {
  source  = "c0x12c/static-website/aws"
  version = "1.0.0"

  name              = "example"
  bucket_prefix     = "example"
  enabled_create_s3 = false
  dns_name          = "app"
  domain_name       = "example.com"
  route53_zone_id   = "<r53_zone_id>"

  cloudfront_distribution_aliases = ["app.example.com"]
  global_tls_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-efgh-5678-ijkl-9012mnopqrst"

  ordered_cache_behaviors = [{
    path_pattern           = "/index.html"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "s3_origin_id"
    query_string           = false
    cookies_forward        = "none"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }]
}

module "cloudfront_logging" {
  source = "../"

  # Use provider in global region `us-east-1`
  # Refer: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logging.html

  name                            = "web-platform"
  log_bucket_arn                  = module.cloudfront_log_bucket.s3_bucket_arn
  aws_cloudfront_distribution_arn = module.static_website.cloudfront_distribution_arn
}

module "cloudfront_log_bucket" {
  source  = "c0x12c/s3/aws"
  version = "1.1.0"

  bucket_name = "cloudfront-log-bucket"
}
