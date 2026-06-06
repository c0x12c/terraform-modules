module "example" {
  source = "../"

  helm_release_name  = "metrics-server"
  namespace          = "kube-system"
  helm_chart_version = "3.12.2"

  node_selector = {}
  tolerations   = []
}
