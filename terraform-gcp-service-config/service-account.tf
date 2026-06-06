module "service_account" {
  source  = "c0x12c/service-account/gcp"
  version = "~> 1.0.0"

  service_account_id         = "${var.name}-${var.environment}"
  enabled_create_custom_role = var.create_custom_role
  roles                      = var.roles
  permissions                = var.permissions
}
