output "cluster_name" {
  value = module.eks.aws_eks_cluster.name
}

output "cluster_arn" {
  value = module.eks.aws_eks_cluster.arn
}

output "cluster_role_arn" {
  value = module.eks.aws_eks_cluster.role_arn
}

output "node_role_name" {
  value = module.eks.aws_iam_role_node.name
}

output "node_role_arn" {
  value = module.eks.aws_iam_role_node.arn
}

output "fargate_profile_pod_execution_role_arn" {
  value = module.eks.fargate_profile.fargate_profile_pod_execution_role_arn
}

output "efs_arn" {
  value = module.eks.efs.arn
}

output "efs_dns_name" {
  value = module.eks.efs.dns_name
}

