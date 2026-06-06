/**
`google_dns_record_set` block provisions a list of DNS records in specified DNS managed zone.
Accepts the DNS zone name through the `dns_zone` variable and the DNS name through the `dns_name` variable.
It dynamically creates records based on the entries in the `custom_records` variable.
Supports multiple record types, TTL values, and custom records.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set
 */
resource "google_dns_record_set" "this" {
  for_each = var.custom_records

  managed_zone = var.dns_zone
  name         = each.key == "@" ? var.dns_name : "${each.key}.${var.dns_name}"
  ttl          = each.value.ttl != null ? each.value.ttl : local.default_ttl
  type         = each.value.type != null ? each.value.type : local.default_record_type
  rrdatas      = each.value.rrdatas
}
