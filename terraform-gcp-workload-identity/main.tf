/**
`google_iam_workload_identity_pool` creates a new IAM workload identity pool in Google Cloud IAM, enabling authentication with external identity providers.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool
 */
resource "google_iam_workload_identity_pool" "this" {
  count = var.create_identity_pool ? 1 : 0

  workload_identity_pool_id = var.pool_id
}

/**
`google_iam_workload_identity_pool_provider` configures a provider for a workload identity pool, allowing external identity providers to authenticate workloads.
The `oidc` block specifies the OIDC provider's issuer URI, and the `attribute_mapping` block defines the mapping of claims from the external identity provider to Google Cloud attributes.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider#example-usage---iam-workload-identity-pool-provider-oidc-basic
 */
resource "google_iam_workload_identity_pool_provider" "this" {
  for_each = var.provider_list

  workload_identity_pool_id          = data.google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = each.key

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  oidc {
    issuer_uri = each.value
  }
}

/**
`google_service_account_iam_binding` assigns IAM roles to the service account, allowing it to access resources based on the role and the principal set defined by the workload identity pool.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_binding
 */
resource "google_service_account_iam_binding" "admin_account_iam" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_id}"
  role               = var.role

  members = [
    "principalSet://iam.googleapis.com/${data.google_iam_workload_identity_pool.this.name}/*"
  ]
}
