output "cluster_name" {
  description = "The name of the cluster, unique within the project and location."
  value       = google_container_cluster.autopilot_gke.name
}

output "cluster_id" {
  description = "An identifier for the GKE resource with format projects/{{project}}/locations/{{zone}}/clusters/{{name}}."
  value       = google_container_cluster.autopilot_gke.id
}

output "cluster_self_link" {
  description = "The server-defined URL for the GKE resource."
  value       = google_container_cluster.autopilot_gke.self_link
}

output "endpoint" {
  description = "The IP address of this cluster's Kubernetes master."
  value       = google_container_cluster.autopilot_gke.endpoint
}

output "master_auth" {
  description = "Base64 encoded public certificate used by clients to authenticate to the cluster endpoint."
  value       = google_container_cluster.autopilot_gke.master_auth
}
