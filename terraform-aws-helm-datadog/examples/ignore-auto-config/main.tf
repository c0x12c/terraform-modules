module "datadog" {
  source = "../.."

  environment  = var.environment
  cluster_name = var.cluster_name

  datadog_site    = var.datadog_site
  datadog_api_key = var.datadog_api_key
  datadog_app_key = var.datadog_app_key

  enabled_agent         = true
  enabled_cluster_agent = true

  ignore_auto_config = ["datadog_cluster_agent"]
}
