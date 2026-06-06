/**
`google_iam_workload_identity_pool` get an IAM workload identity pool from Google Cloud by its id.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_workload_identity_pool
 */
data "google_iam_workload_identity_pool" "this" {
  provider = google-beta

  workload_identity_pool_id = var.pool_id

  depends_on = [google_iam_workload_identity_pool.this]
}
