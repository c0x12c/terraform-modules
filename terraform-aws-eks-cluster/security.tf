#######################################
# Masters
########################################

resource "aws_security_group" "cluster" {
  name        = "${local.cluster_name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow internal connection for cluster"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(
    {
      "Name" = "${local.cluster_name}-node"
    },
    var.node_groups == {} ? {
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    } : {},
    var.enabled_karpenter ? {
      "karpenter.sh/discovery" = local.cluster_name
    } : {}
  )
}
