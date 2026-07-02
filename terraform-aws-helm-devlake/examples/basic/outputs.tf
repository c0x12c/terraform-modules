output "namespace" {
  description = "Namespace DevLake is deployed into."
  value       = module.devlake.namespace
}

output "hostname" {
  description = "Hostname the DevLake UI is served on."
  value       = module.devlake.hostname
}
