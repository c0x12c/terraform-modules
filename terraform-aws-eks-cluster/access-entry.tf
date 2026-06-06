resource "aws_eks_access_entry" "node_role" {
  count = var.authentication_mode == "API" || var.authentication_mode == "API_AND_CONFIG_MAP" ? 1 : 0

  cluster_name  = aws_eks_cluster.master.name
  principal_arn = aws_iam_role.node.arn
}

resource "aws_eks_access_policy_association" "node_role" {
  count = var.authentication_mode == "API" || var.authentication_mode == "API_AND_CONFIG_MAP" ? 1 : 0

  cluster_name  = aws_eks_cluster.master.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.node.arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "auth_role" {
  count = var.authentication_mode == "API" || var.authentication_mode == "API_AND_CONFIG_MAP" ? 1 : 0

  cluster_name  = aws_eks_cluster.master.name
  principal_arn = aws_iam_role.auth_role.arn
}

resource "aws_eks_access_policy_association" "auth_role" {
  count = var.authentication_mode == "API" || var.authentication_mode == "API_AND_CONFIG_MAP" ? 1 : 0

  cluster_name  = aws_eks_cluster.master.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.auth_role.arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "fargate_profile" {
  count = (var.authentication_mode == "API" || var.authentication_mode == "API_AND_CONFIG_MAP") && var.create_fargate_profile_access_entry ? 1 : 0

  cluster_name  = aws_eks_cluster.master.name
  principal_arn = module.fargate_profile.fargate_profile_pod_execution_role_arn
  type          = "FARGATE_LINUX"
}
