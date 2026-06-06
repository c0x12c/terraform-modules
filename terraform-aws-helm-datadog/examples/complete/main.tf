module "datadog" {
  source = "../.."

  environment  = "dev"
  cluster_name = "your-cluster-name"

  datadog_site    = module.config_datadog.site
  datadog_api_key = module.config_datadog.api_key
  datadog_app_key = module.config_datadog.app_key

  enabled_agent                      = true
  enabled_cluster_agent              = true
  enabled_cluster_check              = true
  enabled_container_collect_all_logs = true
  enabled_logs                       = true
  enabled_metric_provider            = true

  http_check_urls = module.config_datadog.http_check_urls

  datadog_envs = [{
    name  = "DD_EKS_FARGATE"
    value = "true"
  }]

  node_selector = {
    "service-type" = "backbone"
  }

  tolerations = [
    {
      key      = "service-type"
      operator = "Equal"
      value    = "backbone"
      effect   = "NoSchedule"
    }
  ]
}