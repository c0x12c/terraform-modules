/**
CertificateMap defines a collection of certificate configurations, which are usable by any associated target proxies
 */
resource "google_certificate_manager_certificate_map" "wildcard_map" {
  name        = "${local.name}-certmap-wildcard"
  description = "${var.domain} certificate map"
}

/**
CertificateMapEntry is a list of certificate configurations, that have been issued for a particular hostname
In this case, it is the wildcard host name
 */
resource "google_certificate_manager_certificate_map_entry" "wildcard_entry" {
  name         = "${local.name}-certmap-wildcard"
  map          = google_certificate_manager_certificate_map.wildcard_map.name
  certificates = [google_certificate_manager_certificate.root_cert.id]
  hostname     = "*.${var.domain}"
}
