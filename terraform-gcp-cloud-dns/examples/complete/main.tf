module "cloud_dns" {
  source = "../../"

  create_new = true

  dns_zone    = "example-com"
  dns_name    = "example.com."
  description = "DNS zone for domain: example.com"
  visibility  = "public"

  custom_records = {
    "web-app" = {
      type    = "CNAME"
      ttl     = 300
      rrdatas = ["alias"]
    }
  }
}
