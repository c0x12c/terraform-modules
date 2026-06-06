output "service_account_key_id" {
  description = "An identifier for the service account key with format projects/{{project}}/serviceAccounts/{{account}}/keys/{{key}}."
  value       = google_service_account_key.this.id
}

output "service_account_key" {
  description = "The private key in JSON format, base64 encoded."
  value       = google_service_account_key.this.private_key
}

output "service_account_id" {
  description = "The service account id."
  value       = google_service_account.this.id
}

output "service_account_name" {
  description = "The service account name."
  value       = google_service_account.this.name
}

output "client_email" {
  description = "The service account email address."
  value       = google_service_account.this.email
}
