output "public_ip" {
  value = google_compute_address.this.address
}

output "ca_cert" {
  value = tls_self_signed_cert.ca.cert_pem
}

output "ssh_public_key" {
  value = tls_private_key.management_ssh_key.public_key_openssh
}

output "ovpn_file" {
  value     = <<-EOT
client
dev tun
proto udp
remote ${local.openvpn_fqdn} 1194
resolv-retry infinite
nobind

# Downgrade privileges after initialization (non-Windows only)
user nobody
group nobody

persist-key
persist-tun

data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305:AES-128-CBC
data-ciphers-fallback AES-128-CBC
reneg-sec 28800

<ca>
${tls_self_signed_cert.ca.cert_pem}
</ca>
EOT
  sensitive = true
}