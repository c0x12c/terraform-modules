output "namespace" {
  description = "Namespace DevLake is deployed into."
  value       = var.namespace
}

output "release_name" {
  description = "Name of the Helm release."
  value       = helm_release.devlake.name
}

output "chart_version" {
  description = "Deployed DevLake chart version."
  value       = helm_release.devlake.version
}

output "hostname" {
  description = "Hostname the DevLake UI is served on."
  value       = var.hostname
}
