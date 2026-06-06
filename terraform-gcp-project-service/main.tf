/**
`google_project_service` allows management of a single API service for a Google Cloud project.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
 */
resource "google_project_service" "project" {
  for_each = toset(var.services)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = var.disable_on_destroy
}
