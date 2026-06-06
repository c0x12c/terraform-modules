output "service_account_name" {
  description = "The service account name."
  value       = module.service_account.service_account_name
}

output "service_account_email" {
  description = "The service account email."
  value       = module.service_account.client_email
}

output "service_account_key" {
  description = "The service account key."
  value       = module.service_account.service_account_key
}

output "dns_record_name" {
  description = "The list of DNS record names."
  value       = try(module.dns[0].dns_record_names, [])
}
