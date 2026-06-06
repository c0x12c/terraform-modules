/**
`google_dns_managed_zone` data source retrieves information about an existing DNS managed zone.
Accepts the DNS zone name through the `dns_zone` variable.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone
 */
data "google_dns_managed_zone" "this" {
  count = var.create_new ? 0 : 1

  name = var.dns_zone
}

/**
`google_dns_managed_zone` resource provisions a DNS managed zone.
Used to avoid creating a new zone if `create_new` is set to `false`.
Accepts the DNS zone name through the `dns_zone` variable and the DNS name through the `dns_name` variable.
Accepts the DNS zone visibility through the `visibility` by default is `public` that exposed to the Internet.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone
 */
resource "google_dns_managed_zone" "this" {
  count = var.create_new ? 1 : 0

  name        = var.dns_zone
  dns_name    = var.dns_name
  description = var.description
  visibility  = var.visibility
}
