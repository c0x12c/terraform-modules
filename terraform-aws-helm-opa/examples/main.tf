module "eks_helm_opa" {
  source = "../"

  helm_release_name  = "opa"
  namespace          = "opa"
  helm_chart_version = "0.1.13"
  opa_image_tag      = "1.4.2"
  create_namespace   = true
}
