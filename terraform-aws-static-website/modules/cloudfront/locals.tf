locals {
  # Response-headers-policy names are unique per AWS ACCOUNT, so a caller that instantiates this
  # module more than once (e.g. for_each over several sites) must give each one its own name or the
  # second create fails on a duplicate name. Default is unchanged for backward compatibility -
  # changing it would force-replace a policy that may be attached and serving for existing callers.
  cloudfront_response_headers_policy_name = coalesce(var.response_headers_policy_name, "cloudfront-headers-policy")
  s3_origin_id                            = "s3-origin-${var.s3_bucket_id}"
  dns_name                                = var.dns_name != null ? "${var.dns_name}.${var.domain_name}" : var.domain_name
}
