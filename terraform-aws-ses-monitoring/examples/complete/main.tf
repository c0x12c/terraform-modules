module "main" {
  source = "../.."

  environment = "dev"
  name        = replace("example1.com", ".", "_")

  ses_identity_ids = {
    "<ses-id>" : "<ses-identity-id>"
  }

  datadog_api_key                       = "<datadog-api-key>"
  datadog_site                          = "https://us3.datadoghq.com/"
  enabled_datadog_dashboard             = true
  datadog_dashboard_environments        = ["dev", "prod"]
  datadog_dashboard_default_environment = "dev"

  enabled_outgoing_email_logs_cloudwatch = true
}
