/**
This block will create only 1 DNS records.
 */
module "dns" {
  source = "../terraform-gcp-cloud-dns"

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
