/**
Provide a resource to manage an API key.
https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/api_key
 */
resource "sendgrid_api_key" "this" {
  for_each = var.api_keys

  name   = each.value.name
  scopes = each.value.scopes
}

/**
Provide a resource to manage a domain authentication.
https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/domain_authentication
 */
resource "sendgrid_domain_authentication" "this" {
  domain             = var.dns_zone_name
  automatic_security = var.automatic_security
  is_default         = var.is_default_authenticated_domain
}

/**
Provide a resource to manage link branding.
https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/link_branding
 */
resource "sendgrid_link_branding" "this" {
  domain     = var.dns_zone_name
  is_default = var.is_default_link_branding
}
