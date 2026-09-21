module "datadog" {
  source = "../.."

  environment  = var.environment
  cluster_name = var.cluster_name

  datadog_site    = var.datadog_site
  datadog_api_key = var.datadog_api_key
  datadog_app_key = var.datadog_app_key
}
