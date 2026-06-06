module "service" {
  source = "../../"

  environment      = "dev"
  name             = "service"
  namespace        = "example"
  create_namespace = true

  roles = [
    "roles/bigquery.dataViewer"
  ]

  hostname     = "service"
  domain_name  = "example.com"
  managed_zone = "example-zone"
  dns_rrdatas  = ["alias"]
  dns_ttl      = 300
}
