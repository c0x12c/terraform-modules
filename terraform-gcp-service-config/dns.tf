/**
This block will create only 1 DNS records.
 */
module "dns" {
  source  = "c0x12c/cloud-dns/gcp"
  version = "~> 0.1.4"

  count = var.managed_zone != null ? 1 : 0

  dns_zone   = var.managed_zone
  dns_name   = "${var.domain_name}."
  create_new = var.create_dns_zone

  custom_records = {
    (var.hostname) = {
      ttl     = var.dns_ttl
      type    = "A"
      rrdatas = var.dns_rrdatas
    }
  }
}
