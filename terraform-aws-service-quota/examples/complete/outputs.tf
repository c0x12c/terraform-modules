output "quotas" {
  description = "Code, applied and default values with request status per quota."
  value       = module.service_quotas.quotas
}

output "quotas_out_of_sync" {
  description = "Quotas whose AWS-applied value differs from code; empty when in sync."
  value       = module.service_quotas.quotas_out_of_sync
}
