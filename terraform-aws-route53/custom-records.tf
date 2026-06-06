/*
aws_route53_record main creates DNS records in the specified Route 53 hosted zone.
It dynamically creates records based on the entries in the `custom_records` variable.
Supports multiple record types, TTL values, and custom records.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
*/
resource "aws_route53_record" "main" {
  for_each = var.custom_records

  name    = each.key
  zone_id = each.value.zone_id != null ? each.value.zone_id : local.dns_zone.id
  type    = each.value.type != null ? each.value.type : local.default_record_type
  ttl     = each.value.ttl != null ? each.value.ttl : local.default_ttl
  records = each.value.records
}
