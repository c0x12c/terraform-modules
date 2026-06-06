module "eks_managed_node_group" {
  source  = "c0x12c/eks-managed-node-group/aws"
  version = "1.0.1"

  for_each = var.node_groups

  name         = each.value.node_group_name
  cluster_name = aws_eks_cluster.master.name
  subnet_ids   = var.private_subnet_ids

  min_size           = each.value.min_size
  max_size           = each.value.max_size
  desired_size       = each.value.desired_size
  cluster_version    = var.cluster_version
  node_group_version = var.node_group_version

  instance_types = each.value.instance_types
  capacity_type  = "ON_DEMAND"

  taints = each.value.taints
  labels = each.value.labels
}
