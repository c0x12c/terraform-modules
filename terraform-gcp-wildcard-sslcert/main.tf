locals {
  name = replace(var.domain, ".", "-")
}

/**
Provides access to a zone's attributes within Google Cloud DNS
 */
data "google_dns_managed_zone" "domain" {
  count = var.managed_zone != null ? 1 : 0

  name = var.managed_zone
}

/**
DnsAuthorization represents a HTTP-reachable backend for a DnsAuthorization.
 */
resource "google_certificate_manager_dns_authorization" "this" {
  name   = local.name
  domain = var.domain
}

/**
Manages a set of DNS records within Google Cloud DNS
 */
resource "google_dns_record_set" "authorization_records" {
  count = var.managed_zone != null ? 1 : 0

  name         = google_certificate_manager_dns_authorization.this.dns_resource_record[0].name
  managed_zone = data.google_dns_managed_zone.domain[0].name
  type         = google_certificate_manager_dns_authorization.this.dns_resource_record[0].type
  ttl          = var.dns_record_set_ttl
  rrdatas      = [google_certificate_manager_dns_authorization.this.dns_resource_record[0].data]
}

/**
Certificate represents a HTTP-reachable backend for a Certificate
 */
resource "google_certificate_manager_certificate" "root_cert" {
  name        = "${local.name}-wildcard"
  description = "The wildcard cert"
  managed {
    domains = [var.domain, "*.${var.domain}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.this.id
    ]
  }
}
