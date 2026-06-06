output "public_ip" {
  value = module.openvpn.public_ip
}

output "ca_cert" {
  value = module.openvpn.ca_cert
}

output "ssh_public_key" {
  value = module.openvpn.ssh_public_key
}

output "ovpn_file" {
  value = module.openvpn.ovpn_file
}
