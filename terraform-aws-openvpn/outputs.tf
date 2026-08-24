output "public_ip" {
  value       = aws_eip.this.public_ip
  description = "The public IP address of the OpenVPN instance."
}

output "ssh_private_key" {
  value       = try(tls_private_key.management_ssh_key[0].private_key_pem, "")
  sensitive   = true
  description = "The private key for the management SSH key pair."
}

output "ssh_public_key" {
  value       = try(tls_private_key.management_ssh_key[0].public_key_openssh, "")
  description = "The public key for the management SSH key pair."
}

# setenv CLIENT_CERT 0 below is load-bearing for OpenVPN Connect. The server runs
# verify-client-cert none, so the profile carries no client certificate, and Connect cannot tell
# whether to source one from the OS keychain or whether the server wants none. It asks the user on
# every connect until told.
#
# It is a setenv rather than a directive so that clients which do not recognise it ignore the line
# instead of failing to parse the profile.
output "ovpn_file" {
  value       = <<-EOT
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

# This profile intentionally has no client certificate
setenv CLIENT_CERT 0
EOT
  description = "OpenVPN client profile (.ovpn) for connecting to this server."
  sensitive   = true
}

output "ca_cert" {
  value       = tls_self_signed_cert.ca.cert_pem
  description = "The OpenVPN CA certificate."
}

output "instance_id" {
  value       = local.instance.id
  description = "The ID of the AWS instance."
}

output "instant_arn" {
  value       = local.instance.arn
  description = "The ARN of the AWS instance."
}
