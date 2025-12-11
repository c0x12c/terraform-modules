output "instance_id" {
  description = "The ID of the Ubuntu desktop instance"
  value       = module.ubuntu_desktop.id
}

output "public_ip" {
  description = "The public IP address of the instance"
  value       = module.ubuntu_desktop.public_ip
}

output "elastic_ip" {
  description = "The Elastic IP address assigned to the instance"
  value       = module.ubuntu_desktop.eip_public_ip
}

output "connection_info" {
  description = "Connection information for the Ubuntu desktop"
  value = {
    rdp_endpoint = "${module.ubuntu_desktop.eip_public_ip}:3389"
    vnc_endpoint = "${module.ubuntu_desktop.eip_public_ip}:5900"
    ssh_command  = "ssh -i <your-key.pem> ubuntu@${module.ubuntu_desktop.eip_public_ip}"
    username     = "ubuntu"
    password     = "ubuntu (CHANGE IMMEDIATELY!)"
  }
}
