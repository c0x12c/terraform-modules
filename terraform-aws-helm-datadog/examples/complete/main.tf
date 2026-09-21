module "datadog" {
  source = "../.."

  environment  = var.environment
  cluster_name = var.cluster_name

  datadog_site    = var.datadog_site
  datadog_api_key = var.datadog_api_key
  datadog_app_key = var.datadog_app_key

  namespace         = "datadog"
  helm_release_name = "datadog"
  chart_version     = "3.110.4"
  timeout           = 1200

  name_override     = "datadog"
  fullname_override = "datadog"

  enable_operator = false

  enabled_agent                      = true
  enabled_cluster_agent              = true
  enabled_cluster_check              = true
  enabled_container_collect_all_logs = true
  enabled_logs                       = true
  enabled_metric_provider            = true

  container_exclude = "kube_namespace:kube-system image:.*pause.*"
  container_include = "kube_namespace:default"

  http_check_urls = ["https://example.com/health"]

  datadog_envs = [{
    name  = "DD_LOG_LEVEL"
    value = "warn"
  }]

  extra_confd = {
    "openmetrics.yaml" = <<-YAML
      cluster_check: true
      init_config:
      instances:
        - openmetrics_endpoint: https://example.com/metrics
          namespace: example
          metrics:
            - example_metric
    YAML
  }

  ignore_auto_config = ["datadog_cluster_agent"]

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
