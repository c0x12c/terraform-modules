resource "aws_eks_access_entry" "this" {
  for_each = { for i, entry in var.access_entries : entry.principal_arn => entry }

  cluster_name      = var.cluster_name
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  principal_arn     = each.value.principal_arn
  type              = try(each.value.type, "STANDARD")
}

resource "aws_eks_access_policy_association" "this" {
  for_each = { for i, entry in var.access_entries : entry.principal_arn => entry if entry.policy_arn != null }

  access_scope {
    namespaces = try(each.value.namespaces, [])
    type       = try(each.value.access_type, "cluster")
  }

  cluster_name = var.cluster_name

  policy_arn    = each.value.policy_arn
  principal_arn = each.value.principal_arn

  depends_on = [
    aws_eks_access_entry.this
  ]
}
