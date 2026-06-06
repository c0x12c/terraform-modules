data "google_client_config" "current" {}

/**
`google_service_account` creates Google Cloud IAM service account that applications or services use to interact with Google Cloud resources.
If you delete and recreate a service account, you must reapply any IAM roles that it had before.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
 */
resource "google_service_account" "this" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = var.description
  disabled     = var.disabled_service_account
}

/**
`google_project_iam_custom_role` creates custom IAM roles within a specific Google Cloud project.
Custom roles allow you to define granular sets of permissions tailored to your use case, different from predefined roles that come with fixed permissions.
 */
resource "google_project_iam_custom_role" "this" {
  count = var.enabled_create_custom_role ? 1 : 0

  role_id     = local.custom_role_name
  title       = local.custom_role_name
  description = var.description
  permissions = var.permissions
}

/**
`google_project_iam_member` updates the IAM policy to grant a role to the member.
This block grants created custom role to the member.
https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/google_project_iam#google_project_iam_member
 */
resource "google_project_iam_member" "custom_role" {
  count = var.enabled_create_custom_role ? 1 : 0

  project = data.google_client_config.current.project
  role    = google_project_iam_custom_role.this[0].id
  member  = "serviceAccount:${google_service_account.this.email}"
}

/**
`google_project_iam_member` updates the IAM policy to grant a role to the member.
This block grants a list of existing roles to the member.
https://registry.terraform.io/providers/hashicorp/google/6.12.0/docs/resources/google_project_iam#google_project_iam_member
 */
resource "google_project_iam_member" "roles" {
  for_each = var.enabled_create_custom_role == false ? toset(var.roles) : toset([])

  project = data.google_client_config.current.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.this.email}"
}

/**
`google_service_account_key` creates service account keys that allow the use of a service account with Google Cloud.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key
 */
resource "google_service_account_key" "this" {
  service_account_id = google_service_account.this.name
}
