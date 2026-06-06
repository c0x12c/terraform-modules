/**
This resource cloudflare_dns_record creates a DNS record in Cloudflare.
https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record
*/

resource "cloudflare_dns_record" "this" {
  zone_id = var.zone_id
  comment = var.comment
  content = var.record_content
  name    = var.name
  proxied = var.enabled_proxy
  tags    = var.tags
  ttl     = var.ttl
  type    = var.type

  settings = {
    ipv4_only = lookup(var.settings, "ipv4_only", false)
    ipv6_only = lookup(var.settings, "ipv6_only", false)
  }
}

/**
This resource cloudflare_page_rule creates a page rule for the DNS record.
https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/page_rule
*/

resource "cloudflare_page_rule" "this" {
  zone_id = var.zone_id
  target  = "${var.name}/*"
  status  = var.cache_status

  actions = {
    cache_level       = lookup(var.page_rule_actions, "cache_level", "cache_everything")
    edge_cache_ttl    = lookup(var.page_rule_actions, "edge_cache_ttl", 86400)
    browser_cache_ttl = lookup(var.page_rule_actions, "browser_cache_ttl", 86400)
  }
}
