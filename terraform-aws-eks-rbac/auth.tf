locals {
  profile_arn = [
    for role in var.profile_roles : templatefile(
      "${path.module}/templates/auth_role.tpl",
      {
        role_arn     = role.role_arn
        privilege    = role.privilege
        profile_type = role.profile_type
        role_name    = role.name
      }
    )
  ]

  custom_clusterrole = [
    for index, role in var.cluster_roles : templatefile(
      "${path.module}/templates/auth_role.tpl",
      {
        role_arn     = aws_iam_role.this_cluster_role[index].arn
        privilege    = "custom:${role.name}-group"
        profile_type = "custom"
        role_name    = role.name
      }
    )
  ]

  custom_namespace_role = [
    for index, role in var.namespace_roles : templatefile(
      "${path.module}/templates/auth_role.tpl",
      {
        role_arn     = aws_iam_role.this_namespace_role[index].arn
        privilege    = "custom:${role.namespace}-${role.privilege}-group"
        profile_type = "custom"
        role_name    = "${role.namespace}-${role.privilege}"
      }
    )
  ]
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles    = <<EOF
${yamldecode(var.existing_aws_auth_data).mapRoles}${join("", distinct(concat(local.profile_arn.*, local.custom_clusterrole.*, local.custom_namespace_role.*)))}
    EOF
    mapUsers    = yamlencode(var.aws_auth_users)
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }

  force = true

  depends_on = [
    kubernetes_cluster_role_binding.this,
    kubernetes_role_binding.this
  ]
}
