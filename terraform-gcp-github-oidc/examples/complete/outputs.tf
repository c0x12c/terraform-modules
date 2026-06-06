output "service_account_email" {
  value = module.github_oidc.service_account_email
}

output "workload_identity_provider" {
  value = module.github_oidc.workload_identity_provider
}
