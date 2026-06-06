output "dns_record_id" {
  value = cloudflare_dns_record.this.id
}

output "page_rule_id" {
  value = cloudflare_page_rule.this.id
}