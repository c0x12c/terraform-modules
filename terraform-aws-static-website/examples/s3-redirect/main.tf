module "static_website" {
  source = "../.."

  name = "example"

  # S3 Config properties
  enabled_create_s3       = false
  existing_s3_bucket_name = "<s3-bucket-id>"
  s3_redirect_domain      = "<redirect-domain-for-s3-bucket>"

  # Route53 Config propeties
  dns_name        = "<dns name>"
  domain_name     = "<domain name>"
  route53_zone_id = "<Route 53 zone id>"

  global_tls_certificate_arn = "<ACM arn for alias in CloudFront>"

  ordered_cache_behaviors = [{
    path_pattern           = "/index.html"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "<target origin id>"
    query_string           = false
    cookies_forward        = "none"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }]
}

