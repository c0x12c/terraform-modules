module "gke_gateway_api" {
  source = "../../"

  ext_gateway_name = "external-gateway"
  create_namespace = true
  cert_map         = "<cert-name>"
}
