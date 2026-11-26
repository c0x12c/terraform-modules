output "parent_folder_uid" {
  description = "Uid of the project parent folder."
  value       = grafana_folder.parent.uid
}

output "env_folder_uids" {
  description = "Folder uid per environment."
  value       = { for env, f in grafana_folder.env : env => f.uid }
}

output "dashboard_uids" {
  description = "Dashboard uid keyed by <env>/<preset>."
  value       = { for key, d in grafana_dashboard.this : key => d.uid }
}
