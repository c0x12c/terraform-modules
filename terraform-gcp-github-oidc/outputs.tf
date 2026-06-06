output "service_account_email" {
  description = "The email address of the GCP service account."
  value       = "${var.gcp_service_account_id}@${var.gcp_project_id}.iam.gserviceaccount.com"
}

output "workload_identity_provider" {
  description = "The full resource name of the Workload Identity Provider in the specified GCP project."
  value       = "projects/${var.gcp_project_id}/locations/global/workloadIdentityPools/${var.gcp_pool_id}/providers/${var.gcp_provider_id}"
}
