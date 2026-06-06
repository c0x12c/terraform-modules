/*
https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
Generate a Certificate Authority
 */
resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = var.domain_name
    organization = var.organization
  }

  dns_names = var.custom_cert_dns_names != null ? var.custom_cert_dns_names : [
    var.domain_name,
    "*.${var.domain_name}",
  ]

  validity_period_hours = 438000 # ~50 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "cert_signing",
  ]
}

/*
https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
Generate OpenVPN server certificates
 */
resource "tls_private_key" "server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name = "server"
  }
}

/*
https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
Sign OpenVPN server cert request by the CA
*/
resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 438000 # ~50 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "cert_signing",
  ]
}
