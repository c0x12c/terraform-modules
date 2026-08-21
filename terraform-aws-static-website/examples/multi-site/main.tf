locals {
  sites = {
    app = {
      dns_name = "app"
      csp      = "default-src 'self'; frame-ancestors 'none'; base-uri 'self';"
    }
    console = {
      dns_name = "console"
      csp      = "default-src 'self'; img-src 'self' data:; frame-ancestors 'none'; base-uri 'self';"
    }
  }
}

# Response headers policy names are unique per AWS ACCOUNT, so each instance
# needs its own response_headers_policy_name - otherwise the second one fails to
# create on a duplicate name. Leaving it unset keeps the historical default
# name, which is what an existing single-site caller already has.
module "static_website" {
  source   = "../.."
  for_each = local.sites

  name              = each.key
  bucket_prefix     = each.key
  enabled_create_s3 = true
  dns_name          = each.value.dns_name
  domain_name       = "example.com"
  route53_zone_id   = "<r53_zone_id>"

  cloudfront_distribution_aliases = ["${each.value.dns_name}.example.com"]
  global_tls_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-efgh-5678-ijkl-9012mnopqrst"

  enabled_response_headers_policy = true
  response_headers_policy_name    = "${each.key}-headers-policy"

  content_security_policy = {
    override                = true
    content_security_policy = each.value.csp
  }

  content_type_options = {
    override = true
  }
}
