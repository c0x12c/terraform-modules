module "datadog" {
  source = "../.."

  environment  = var.environment
  cluster_name = var.cluster_name

  datadog_site    = var.datadog_site
  datadog_api_key = var.datadog_api_key
  datadog_app_key = var.datadog_app_key

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
}
