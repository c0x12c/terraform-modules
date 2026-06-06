module "efs" {
  source  = "c0x12c/eks-efs/aws"
  version = "1.0.0"

  count                     = var.enabled_efs == true ? 1 : 0
  name                      = local.cluster_name
  environment               = var.environment
  private_subnet_ids        = var.private_subnet_ids
  cluster_security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id

  filesystem_encrypted        = var.filesystem_encrypted
  filesystem_performance_mode = var.filesystem_performance_mode
  filesystem_throughput_mode  = var.filesystem_throughput_mode
  efs_filesystem_name         = var.efs_filesystem_name
  efs_storage_class_name      = var.efs_storage_class_name
  efs_backup_policy_status    = var.efs_backup_policy_status
  efs_lifecycle_policy        = var.efs_lifecycle_policy


  depends_on = [aws_eks_cluster.master]
}
