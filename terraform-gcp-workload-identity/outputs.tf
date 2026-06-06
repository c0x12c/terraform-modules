output "workload_identity_provider" {
  description = "A list of workload identity providers."
  value       = google_iam_workload_identity_pool_provider.this
}
