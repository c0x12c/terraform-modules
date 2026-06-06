output "aws_eks_cluster" {
  value       = aws_eks_cluster.master
  sensitive   = true
  description = "The EKS cluster master details, including API server endpoint and certificate authority"
}

output "aws_iam_role_node" {
  value       = aws_iam_role.node
  description = "The IAM role assigned to the EKS worker nodes for managing permissions"
}

output "eks_default_auth_role_arn" {
  value       = aws_iam_role.auth_role.arn
  description = "The ARN of the IAM role used for default EKS authentication"
}

output "aws_iam_instance_profile_node" {
  value       = aws_iam_instance_profile.node
  description = "The instance profile associated with the EKS worker nodes"
}

output "aws_security_group_cluster" {
  value       = aws_security_group.cluster
  description = "The security group applied to the EKS cluster for network control"
}

output "fargate_profile" {
  value       = module.fargate_profile
  description = "Details of the Fargate profile configured for the EKS cluster"
}

output "oidc_provider" {
  value       = aws_iam_openid_connect_provider.eks
  description = "The OpenID Connect (OIDC) provider associated with the EKS cluster for IAM roles"
}

output "efs" {
  value       = try(module.efs[0].efs, null)
  description = "The Amazon EFS (Elastic File System) configuration for the cluster, if available"
}

output "aws_eks_cluster_auth_data" {
  value       = local.aws_auth_configmap_data
  description = "The ConfigMap data for managing EKS cluster authentication"
}

output "datadog_agent_cluster_role_name" {
  # we need to output a var because it has a default value
  value       = var.datadog_agent_cluster_role_name
  description = "Name of the ClusterRole to create in order to configure Datadog Agents"
}
