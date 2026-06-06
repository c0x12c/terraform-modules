module "eks_helm_datadog" {
  source = "../"

  cluster_name    = "my-eks-cluster"
  namespace       = "datadog"
  datadog_api_key = "YOUR_SUPER_SECRET_API_KEY"
  datadog_app_key = "YOUR_SUPER_SECRET_APP_KEY"
  environment     = "DEV"
  datadog_site    = "datadoghq.com"
  datadog_envs = [{
    name  = "DD_APM_ENABLED"
    value = "true"
  }]
  node_selector = {}
  tolerations   = []
}
