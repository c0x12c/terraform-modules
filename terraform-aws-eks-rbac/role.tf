resource "aws_iam_role" "this_cluster_role" {
  count = local.cluster_roles_count

  name                  = "${var.cluster_name}-${var.cluster_roles[count.index].name}-clusterrole"
  assume_role_policy    = data.aws_iam_policy_document.this_cluster_role[count.index].json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
}

resource "aws_iam_role" "this_namespace_role" {
  count = local.namespace_role_count

  name                  = "${var.cluster_name}--${var.namespace_roles[count.index].namespace}-${var.namespace_roles[count.index].privilege}-namespace-role"
  assume_role_policy    = data.aws_iam_policy_document.this_namespace_role[count.index].json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
}
