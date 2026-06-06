module "fargate_profile" {
  source  = "c0x12c/eks-fargate-profile/aws"
  version = "1.0.0"

  create = var.create_fargate_profile

  # Fargate Profile
  cluster_name      = aws_eks_cluster.master.name
  cluster_ip_family = "ipv4"
  name              = "${aws_eks_cluster.master.name}-fargate"
  subnet_ids        = var.private_subnet_ids
  fargate_profiles  = var.fargate_profiles
  timeouts          = var.fargate_timeouts

  tags = {
    Name = "${local.cluster_name}-node"
  }
}

resource "kubernetes_namespace" "fargate" {
  for_each = local.namespaces

  metadata {
    name = each.value
  }
}
