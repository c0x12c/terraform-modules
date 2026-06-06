output "dns_record_names" {
  description = "The DNS record name list created"
  value       = [for key, record in google_dns_record_set.this : trimsuffix(record.name, ".")]
}
