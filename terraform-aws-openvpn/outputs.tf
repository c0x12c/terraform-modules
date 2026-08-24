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

# The server runs verify-client-cert none, so this profile carries no client certificate.
# Without this line OpenVPN Connect cannot tell whether that means "fetch one from the OS
# keychain" or "the server wants none", and asks the user on every connect. A setenv rather
# than a directive so clients that do not recognise it ignore it instead of failing to parse.
setenv CLIENT_CERT 0
EOT
  sensitive = true
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
