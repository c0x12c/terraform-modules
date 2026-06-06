locals {
  network_tags = concat(
    [var.vpn_name],
    var.network_tags
  )

  openvpn_config = {
    ca_cert                     = tls_self_signed_cert.ca.cert_pem
    server_cert                 = tls_locally_signed_cert.server.cert_pem
    server_private_key          = tls_private_key.server.private_key_pem
    management_password         = random_password.management_password.result
    openvpn_auth_oauth2_version = var.openvpn_auth_oauth2_version
    openvpn_fqdn                = local.openvpn_fqdn
    openvpn_ip_pool             = var.openvpn_ip_pool
    oauth2_client_id            = var.oauth2_client_id
    oauth2_client_secret        = var.oauth2_client_secret
    route_network_cidrs         = var.route_network_cidrs
  }
}
