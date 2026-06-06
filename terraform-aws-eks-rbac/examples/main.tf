locals {
  account_id = "1234567890"
}

module "eks-rbac" {
  source = "../"

  cluster_name = "example"

  cluster_roles = [
    {
      name      = "admin"
      privilege = "admin"
      trusted_role_arn = [
        "arn:aws:iam::${local.account_id}:role/admin-role-arn"
      ]
    },
    {
      name      = "developer"
      privilege = "developer"
      trusted_role_arn = [
        "arn:aws:iam::${local.account_id}:role/developer-role-arn"
      ]
    }
  ]

  namespace_roles = [
    {
      namespace = "service-bot"
      privilege = "readonly"
      trusted_role_arn = [
        "arn:aws:iam::${local.account_id}:role/service-bot-readonly-role-arn"
      ]
    },
    {
      namespace = "service-crypto"
      privilege = "developer"
      trusted_role_arn = [
        "arn:aws:iam::${local.account_id}:role/service-crypto-developer-role-arn"
      ]
    }
  ]

  profile_roles = [
    {
      role_arn     = "arn:aws:iam::${local.account_id}:role/node-role-arn"
      profile_type = "node"
      privilege    = "node"
      name         = "node"
    },
    {
      role_arn     = "arn:aws:iam::${local.account_id}:role/admin-role-arn"
      profile_type = "custom"
      privilege    = "admin"
      name         = "master-role"
    },
    {
      role_arn     = "arn:aws:iam::${local.account_id}:role/fargate-role-arn"
      profile_type = "fargate"
      privilege    = "fargate"
      name         = "fargate"
    }
  ]

  aws_auth_users = [
    {
      userarn  = ""
      username = "jenkins"
      groups   = ["system:masters"]
    }
  ]
}
