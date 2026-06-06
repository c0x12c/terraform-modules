output "github_provider_name" {
  value = module.workload_identity.workload_identity_provider["github"].name
}

output "jenkins_provider_name" {
  value = module.workload_identity.workload_identity_provider["jenkins"].name
}
