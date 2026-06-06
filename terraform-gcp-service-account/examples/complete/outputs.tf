output "service_account_key_id" {
  description = "An identifier for the service account key with format projects/{{project}}/serviceAccounts/{{account}}/keys/{{key}}."
  value       = module.service_account.service_account_key_id
}

output "service_account_key" {
  description = "The private key in JSON format, base64 encoded."
  value       = module.service_account.service_account_key
  sensitive   = true
}

output "service_account_id" {
  description = "The service account id."
  value       = module.service_account.service_account_id
}

output "service_account_name" {
  description = "The service account name."
  value       = module.service_account.service_account_name
}

output "client_email" {
  description = "The service account email address."
  value       = module.service_account.client_email
}
