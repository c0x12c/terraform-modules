locals {
  default_fqdn = "${var.jenkins_dns_name}.${var.domain}"
  jenkins_fqdn = var.jenkins_fqdn != "" ? var.jenkins_fqdn : local.default_fqdn

  general_secret_configs = flatten([
    for key, value in var.general_secrets :
    {
      secret_key   = key
      secret_value = value
    }
  ])

  admin_user_list    = var.google_user_list.admin
  executor_user_list = var.google_user_list.executor
  viewer_user_list   = var.google_user_list.viewer
}
