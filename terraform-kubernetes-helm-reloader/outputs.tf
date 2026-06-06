output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.this.name
}

output "helm_release_namespace" {
  description = "Namespace where Reloader is deployed"
  value       = helm_release.this.namespace
}

output "helm_release_version" {
  description = "Version of the Helm release"
  value       = helm_release.this.version
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = helm_release.this.status
}

output "namespace_name" {
  description = "Name of the namespace where Reloader is deployed"
  value       = var.namespace
}

output "service_account_name" {
  description = "Name of the service account (managed by Helm chart)"
  value       = "reloader"
}
