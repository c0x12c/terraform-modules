resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
  name       = var.aws_load_balancer_controller_name
  namespace  = var.namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_load_balancer_controller_chart_version

  set = concat(
    [for key, value in local.helm_release_set : {
      name  = key
      value = value
    }],
    [for key, value in var.node_selector : {
      name  = "nodeSelector.${key}"
      value = value
    }],
    [for key, value in var.tolerations : {
      name  = "tolerations[${key}].key"
      value = lookup(value, "key", "")
    }],
    [for key, value in var.tolerations : {
      name  = "tolerations[${key}].operator"
      value = lookup(value, "operator", "")
    }],
    [for key, value in var.tolerations : {
      name  = "tolerations[${key}].value"
      value = lookup(value, "value", "")
    }],
    [for key, value in var.tolerations : {
      name  = "tolerations[${key}].effect"
      value = lookup(value, "effect", "")
    }]
  )
}
