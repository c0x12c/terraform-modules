resource "aws_route53_record" "this" {
  name    = local.dns_name
  zone_id = var.route53_zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  count = var.use_www_domain ? 1 : 0

  name    = "www.${local.dns_name}"
  zone_id = var.route53_zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wildcard" {
  count = var.use_wildcard_domain ? 1 : 0

  name    = "*.${local.dns_name}"
  zone_id = var.route53_zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}
