/**
`kubernetes_namespace` creates namespace within K8S cluster.
This block is used to create a namespace for gateway.
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace
 */
resource "kubernetes_namespace" "gateway_api" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

/**
`kubernetes_manifest` creates K8S resource using manifest configuration.
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest
 */
resource "kubernetes_manifest" "external_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.ext_gateway_name
      namespace = var.namespace
      annotations = {
        "networking.gke.io/certmap" = var.cert_map
      }
    }
    spec = {
      gatewayClassName = var.ext_gateway_class_name
      listeners = [
        {
          name     = "https"
          protocol = "HTTPS"
          port     = 443
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }

  dynamic "field_manager" {
    for_each = var.enabled_field_manager ? [1] : []
    content {
      name            = "terraform"
      force_conflicts = true
    }
  }

  depends_on = [
    kubernetes_namespace.gateway_api
  ]
}

/**
`time_sleep` manages a resource that delays creation and/or destruction, typically for further resources.
This prevents cross-platform compatibility and destroy-time issues with using the local-exec provisioner.
This block is used to awaiting for gateway IP creation.
https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep
 */
resource "time_sleep" "this" {
  create_duration = var.create_duration

  depends_on = [kubernetes_manifest.external_gateway]
}

/**
This block is used to retrieve created gateway information.
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/resource
 */
data "kubernetes_resource" "external_gateway" {
  api_version = "gateway.networking.k8s.io/v1"
  kind        = "Gateway"
  metadata {
    name      = var.ext_gateway_name
    namespace = var.namespace
  }

  depends_on = [time_sleep.this]
}
