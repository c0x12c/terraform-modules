##### Open Policy Agent  ###############################
resource "helm_release" "opa" {
  name             = var.helm_release_name
  repository       = "https://spartan-stratos.github.io/helm-charts/"
  chart            = "spartan"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace

  set {
    name  = "image.repository"
    value = "openpolicyagent/opa"
  }

  set {
    name  = "image.tag"
    value = var.opa_image_tag
  }

  set {
    name  = "containerPort"
    value = 8181
  }

  set_list {
    name  = "args"
    value = ["run", "--ignore=.*", "--server", "--addr=:8181"]
  }
}
