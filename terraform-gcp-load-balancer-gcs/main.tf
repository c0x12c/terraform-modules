/**
This google_compute_global_address resource creates a global static IP address for the load balancer.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
*/

resource "google_compute_global_address" "this" {
  project      = var.project_id
  name         = "${var.prefix_name}-lb-ip-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

/**
This google_compute_backend_bucket resource configures a backend bucket for serving content from a Google Cloud Storage bucket.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket
*/

resource "google_compute_backend_bucket" "this" {
  provider = google
  project  = var.project_id

  name        = "${var.prefix_name}-bucket"
  bucket_name = var.bucket_name
  enable_cdn  = var.enable_cdn
}

/**
This google_compute_url_map resource defines how requests are routed to the backend bucket.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map
*/

resource "google_compute_url_map" "bucket" {
  provider = google
  project  = var.project_id

  name        = "${var.prefix_name}-lb"
  description = "URL map for ${var.prefix_name}"

  default_service = google_compute_backend_bucket.this.self_link
}

/**
This google_compute_target_http_proxy resources create HTTP proxy for the load balancer.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy
*/

resource "google_compute_target_http_proxy" "http" {
  count   = var.enable_http ? 1 : 0
  project = var.project_id
  name    = "${var.prefix_name}-http-proxy"
  url_map = google_compute_url_map.bucket.id
}

/**
This google_compute_global_forwarding_rule resource creates a global forwarding rule for HTTP traffic.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule
*/

resource "google_compute_global_forwarding_rule" "http" {
  count                 = var.enable_http ? 1 : 0
  provider              = google
  project               = var.project_id
  name                  = "${var.prefix_name}-http-rule"
  target                = google_compute_target_http_proxy.http[0].self_link
  ip_address            = google_compute_global_address.this.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

/**
This google_compute_managed_ssl_certificate resource creates a managed SSL certificate for the load balancer.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate
*/

resource "google_compute_managed_ssl_certificate" "this" {
  count = var.enable_ssl ? 1 : 0

  name = "${var.prefix_name}-ssl"
  managed {
    domains = ["${var.domain_name}"]
  }
}

/**
This google_compute_target_https_proxy resource creates an HTTPS proxy for the load balancer.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy
*/

resource "google_compute_target_https_proxy" "https" {
  count   = var.enable_ssl ? 1 : 0
  project = var.project_id
  name    = "${var.prefix_name}-https-proxy"
  url_map = google_compute_url_map.bucket.id

  certificate_map = var.certificate_map
}

/**
This google_compute_global_forwarding_rule resource creates a global forwarding rule for HTTPS traffic.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule
*/

resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.enable_ssl ? 1 : 0
  provider              = google
  project               = var.project_id
  name                  = "${var.prefix_name}-https-rule"
  target                = google_compute_target_https_proxy.https[0].self_link
  ip_address            = google_compute_global_address.this.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
