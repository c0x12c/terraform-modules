data "aws_eks_addon_version" "vpc_cni_latest" {
  count              = var.addons_vpc_cni_version == null ? 1 : 0
  addon_name         = "vpc-cni"
  kubernetes_version = aws_eks_cluster.master.version
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = local.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = var.addons_vpc_cni_version != null ? var.addons_vpc_cni_version : data.aws_eks_addon_version.vpc_cni_latest[0].version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_cluster.master]
}

data "aws_eks_addon_version" "kube_proxy_latest" {
  count              = var.addons_kube_proxy_version == null ? 1 : 0
  addon_name         = "kube-proxy"
  kubernetes_version = aws_eks_cluster.master.version
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = local.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = var.addons_kube_proxy_version != null ? var.addons_kube_proxy_version : data.aws_eks_addon_version.kube_proxy_latest[0].version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_cluster.master]
}

data "aws_eks_addon_version" "coredns_latest" {
  count              = var.addons_coredns_version == null ? 1 : 0
  addon_name         = "coredns"
  kubernetes_version = aws_eks_cluster.master.version
}

resource "aws_eks_addon" "coredns_ec2" {
  count = var.compute_type == "ec2" ? 1 : 0

  addon_name                  = "coredns"
  addon_version               = var.addons_coredns_version != null ? var.addons_coredns_version : data.aws_eks_addon_version.coredns_latest[0].version
  cluster_name                = local.cluster_name
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  configuration_values = jsonencode({
    replicaCount = var.coredns.replica_count
    nodeSelector = var.coredns.node_selector
    tolerations  = var.coredns.tolerations
  })

  depends_on = [aws_eks_cluster.master, module.eks_managed_node_group]
}

resource "aws_eks_addon" "coredns_fargate" {
  count = var.compute_type == "fargate" ? 1 : 0

  addon_name                  = "coredns"
  addon_version               = var.addons_coredns_version != null ? var.addons_coredns_version : data.aws_eks_addon_version.coredns_latest[0].version
  cluster_name                = local.cluster_name
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  configuration_values = jsonencode({
    computeType = "fargate"
  })

  depends_on = [aws_eks_cluster.master, module.fargate_profile]
}

data "aws_eks_addon_version" "efs_csi_driver_latest" {
  count              = var.addons_efs_csi_driver_version == null ? 1 : 0
  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = aws_eks_cluster.master.version
}

resource "aws_iam_role" "efs_csi_driver_role" {
  count = var.compute_type == "ec2" ? 1 : 0
  name  = "${var.name}-efs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.master.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.master.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver_policy_attachment" {
  count      = var.compute_type == "ec2" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_driver_role[0].name
}

resource "aws_eks_addon" "efs_csi_driver" {
  count = var.compute_type == "ec2" ? 1 : 0

  addon_name                  = "aws-efs-csi-driver"
  addon_version               = var.addons_efs_csi_driver_version != null ? var.addons_efs_csi_driver_version : data.aws_eks_addon_version.efs_csi_driver_latest[0].version
  cluster_name                = local.cluster_name
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  service_account_role_arn = aws_iam_role.efs_csi_driver_role[0].arn

  configuration_values = jsonencode({
    controller = {
      replicaCount = var.efs_csi.replica_count
      nodeSelector = var.efs_csi.node_selector
      tolerations  = var.efs_csi.tolerations
    }
  })
  depends_on = [aws_eks_cluster.master, module.eks_managed_node_group]
}
