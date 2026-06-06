locals {
  custom_role_name = replace(var.service_account_id, "-", ".")
}
