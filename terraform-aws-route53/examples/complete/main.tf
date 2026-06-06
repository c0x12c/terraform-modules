module "route53" {
  source = "../../"

  dns_zone = "example.com"

  create_new = true

  custom_records = {
    "web-app" = {
      type    = "CNAME"
      ttl     = 300
      records = ["alias"]
    }
  }
}
