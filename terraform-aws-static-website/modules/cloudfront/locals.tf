locals {
  cloudfront_response_headers_policy_name = "cloudfront-headers-policy"
  s3_origin_id                            = "s3-origin-${var.s3_bucket_id}"
  dns_name                                = var.dns_name != null ? "${var.dns_name}.${var.domain_name}" : var.domain_name
}
