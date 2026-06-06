/*
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
*/
data "google_compute_network" "this" {
  name = var.vpc_name
}

/*
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
*/

resource "google_compute_firewall" "egress_vpn" {
  name    = "${var.vpn_name}-egress"
  network = data.google_compute_network.this.name

  allow {
    protocol = "all"
    ports    = []
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
}

/*
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
Allow connections to OpenVPN port
*/
resource "google_compute_firewall" "udp_vpn" {
  name    = "${var.vpn_name}-udp"
  network = data.google_compute_network.this.name

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}

/*
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
Allow Certbot TLS renewal
*/
resource "google_compute_firewall" "http_vpn" {
  name    = "${var.vpn_name}-http"
  network = data.google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}

/*
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
Allow Google OAuth 2.0 callback
*/
resource "google_compute_firewall" "https_vpn" {
  name    = "${var.vpn_name}-https"
  network = data.google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}
