module "service_account" {
  source = "../terraform-gcp-service-account"

  service_account_id         = "${var.name}-${var.environment}"
  enabled_create_custom_role = var.create_custom_role
  roles                      = var.roles
  permissions                = var.permissions
}
