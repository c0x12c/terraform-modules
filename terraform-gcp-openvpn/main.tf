/*
https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
*/
resource "random_password" "management_password" {
  length  = 24
  special = false
}

/*
https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
*/
resource "tls_private_key" "management_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
*/
resource "google_compute_address" "this" {
  address_type = "EXTERNAL"
  description  = "External IP for ${var.vpn_name}"

  name   = "${var.vpn_name}-network-ip"
  region = var.region
}

/*
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
*/
resource "google_compute_instance" "default" {
  name         = var.vpn_name
  machine_type = var.machine_type
  zone         = var.zone

  network_interface {
    network    = var.vpc_name
    subnetwork = var.vpc_subnet

    access_config {
      nat_ip = google_compute_address.this.address
    }
  }

  boot_disk {
    initialize_params {
      image = "${var.image_distro}-${var.image_version}"
      type  = "pd-ssd"
      size  = var.disk_boot_size
    }
  }

  metadata = {
    ssh-keys = "management:${tls_private_key.management_ssh_key.public_key_openssh}"
  }

  tags                      = local.network_tags
  allow_stopping_for_update = true

  metadata_startup_script = templatefile("${path.module}/scripts/install_openvpn.sh", local.openvpn_config)
}

