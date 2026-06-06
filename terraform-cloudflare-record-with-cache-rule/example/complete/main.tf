locals {
  cloudflare_domain     = "example.com"
  cloudflare_zone_id    = "<YOUR CLOUDFLARE ZONE ID HERE>"
  cloudflare_account_id = "<YOUR CLOUDFLARE ACCOUNT ID HERE>"
}

module "cloudflare_cdn_for_static_site" {
  source = "../.."

  zone_id = local.cloudflare_zone_id

  name           = "img.${local.cloudflare_domain}"
  record_content = module.bucket_photos_load_balancer.ip_address
  enabled_proxy  = true
  comment        = "CDN of static site"

  page_rule_actions = {
    cache_level       = "cache_everything"
    edge_cache_ttl    = 2419200
    browser_cache_ttl = 31536000
  }
}