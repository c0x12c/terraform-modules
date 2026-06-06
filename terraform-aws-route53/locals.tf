locals {
  default_record_type = "CNAME"
  default_ttl         = 3600

  dns_zone = var.create_new ? aws_route53_zone.dns_zone[0] : data.aws_route53_zone.dns_zone[0]
}
