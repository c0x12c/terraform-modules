# A site with a single default cache behavior - no ordered_cache_behaviors.
# enabled_response_headers_policy is all that is needed: the policy attaches to
# the default behavior, so the headers are sent on every response.
module "static_website" {
  source = "../.."

  name              = "example"
  bucket_prefix     = "example"
  enabled_create_s3 = true
  dns_name          = "app"
  domain_name       = "example.com"
  route53_zone_id   = "<r53_zone_id>"

  cloudfront_distribution_aliases = ["app.example.com"]
  global_tls_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-efgh-5678-ijkl-9012mnopqrst"

  enabled_response_headers_policy = true

  # CloudFront caps this value at 1783 characters and rejects a longer one when
  # the change is applied, not when it is planned.
  content_security_policy = {
    override                = true
    content_security_policy = "default-src 'self'; object-src 'none'; frame-ancestors 'none'; base-uri 'self';"
  }

  strict_transport_security = {
    override                   = true
    access_control_max_age_sec = 63072000
    include_subdomains         = true
    preload                    = true
  }

  content_type_options = {
    override = true
  }

  referrer_policy = {
    override        = true
    referrer_policy = "strict-origin-when-cross-origin"
  }
}
