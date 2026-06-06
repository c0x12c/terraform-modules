resource "aws_service_discovery_http_namespace" "this" {
  count = var.enabled_service_connect ? 1 : 0

  name = var.cluster_name
}
