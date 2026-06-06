locals {
  region = var.region != null ? var.region : data.aws_region.current.name

  cluster_name = "${var.name}-eks-${var.environment}"
  namespaces   = { for namespace in var.custom_namespaces : namespace => namespace }
}
