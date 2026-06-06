module "service_account" {
  source  = "c0x12c/service-account/gcp"
  version = "1.0.0"

  service_account_id = var.datadog_account_id
  roles              = var.datadog_roles
}

/**
This block grants token creator role to the Datadog principal account.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_member
 */
resource "google_service_account_iam_member" "this" {
  service_account_id = module.service_account.service_account_id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = format("serviceAccount:%s", datadog_integration_gcp_sts.this.delegate_account_email)
}

/**
Provides a Datadog Integration GCP Sts resource.
This can be used to create and manage Datadog - Google Cloud Platform integration.
https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_gcp_sts
 */
resource "datadog_integration_gcp_sts" "this" {
  client_email             = module.service_account.client_email
  host_filters             = [var.host_filters]
  automute                 = var.automute
  is_cspm_enabled          = var.is_cspm_enabled
  metric_namespace_configs = local.enabled_services
}
