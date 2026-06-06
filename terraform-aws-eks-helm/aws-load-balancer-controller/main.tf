resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
  name       = var.aws_load_balancer_controller_name
  namespace  = var.namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_load_balancer_controller_chart_version

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "serviceAccount.name"
    value = var.aws_load_balancer_controller_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  set {
    name  = "region"
    value = local.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  dynamic "set" {
    for_each = var.node_selector
    content {
      name  = "nodeSelector.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "tolerations[${set.key}].key"
      value = lookup(set.value, "key", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "tolerations[${set.key}].operator"
      value = lookup(set.value, "operator", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "tolerations[${set.key}].value"
      value = lookup(set.value, "value", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "tolerations[${set.key}].effect"
      value = lookup(set.value, "effect", "")
    }
  }
}
