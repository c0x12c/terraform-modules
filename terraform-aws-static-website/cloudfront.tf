module "cloudfront" {
  source = "./modules/cloudfront"

  dns_name                        = var.dns_name
  domain_name                     = var.domain_name
  route53_zone_id                 = var.route53_zone_id
  s3_bucket_id                    = var.enabled_create_s3 ? module.s3[0].s3_bucket_id : data.aws_s3_bucket.this[0].id
  s3_redirect_domain              = var.s3_redirect_domain
  ssl_certificate_arn             = var.global_tls_certificate_arn
  viewer_protocol_policy          = var.viewer_protocol_policy
  minimum_protocol_version        = var.minimum_protocol_version
  price_class                     = var.price_class
  use_www_domain                  = var.use_www_domain
  use_wildcard_domain             = var.use_wildcard_domain
  distribution_aliases            = var.cloudfront_distribution_aliases
  ordered_cache_behaviors         = var.ordered_cache_behaviors
  enabled_response_headers_policy = var.enabled_response_headers_policy
  referrer_policy                 = var.referrer_policy
  content_security_policy         = var.content_security_policy
  strict_transport_security       = var.strict_transport_security
  content_type_options            = var.content_type_options
  wafv2_arn                       = var.wafv2_arn
  default_cache_behavior          = var.default_cache_behavior
}
