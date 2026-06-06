locals {
  fargate_profile_pod_execution_role_arn = module.fargate_profile.fargate_profile_pod_execution_role_arn

  aws_auth_configmap_data = {
    mapRoles = yamlencode(concat(
      [
        for node_group_name, node_group in var.node_groups : {
          rolearn  = module.eks_managed_node_group[node_group_name].node_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:bootstrappers", "system:nodes"]
        }
      ],
      [{
        rolearn  = aws_iam_role.node.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
      }]
      ,
      [{
        rolearn  = aws_iam_role.auth_role.arn
        username = "master-role"
        groups = [
          "system:masters",
        ]
      }]
      ,
      [{
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/jenkins-oidc-role"
        username = "oidc-role"
        groups = [
          "system:masters",
        ]
      }]
      ,
      # Fargate profile
      [{
        rolearn  = local.fargate_profile_pod_execution_role_arn
        username = "system:node:{{SessionName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
          "system:node-proxier",
        ]
      }]
    ))
    mapUsers    = yamlencode(var.aws_auth_users)
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = var.authentication_mode == "CONFIG_MAP" || var.authentication_mode == "API_AND_CONFIG_MAP" ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    ignore_changes = [data]
  }

  force = true # Ensures the config map is updated forcefully if necessary

  depends_on = [
    module.eks_managed_node_group,
    module.fargate_profile
  ]
}
