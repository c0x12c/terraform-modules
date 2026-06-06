###############################
## MASTER IAM ROLE
###############################
locals {
  master_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    aws_iam_policy.k8s_masters.arn
  ]
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "k8s_masters_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
    ]
    resources = ["*"]
    sid       = "kopsK8sEC2MasterPermsDescribeResources"
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateRoute",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:ModifyInstanceAttribute",
    ]
    resources = ["*"]
    sid       = "kopsK8sEC2MasterPermsAllResources"
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:RevokeSecurityGroupIngress",
    ]
    resources = ["*"]
    sid       = "kopsK8sEC2MasterPermsTaggedResources"
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:GetAsgForInstance",
    ]
    resources = ["*"]
    sid       = "kopsK8sASMasterPermsAllResources"
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]
    resources = ["*"]
    sid       = "kopsK8sASMasterPermsTaggedResources"
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:*",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancerPolicy",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DetachLoadBalancerFromSubnets",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
    ]
    resources = ["*"]
    sid       = "kopsK8sELBMasterPermsRestrictive"
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
    ]
    resources = ["*"]
    sid       = "kopsMasterCertIAMPerms"
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
    sid       = "kopsK8sECR"
  }
}

resource "aws_iam_role" "master" {
  name = "${local.cluster_name}-terraform-master-cluster"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


resource "aws_iam_policy" "k8s_masters" {
  name = "masters-${local.cluster_name}"

  policy = data.aws_iam_policy_document.k8s_masters_policy.json
}

resource "aws_iam_role_policy_attachment" "master_policy_attachments" {
  count      = length(local.master_policy_arns)
  policy_arn = local.master_policy_arns[count.index]
  role       = aws_iam_role.master.name
  depends_on = [aws_iam_policy.k8s_masters]
}

###############################
## NODE IAM ROLE
###############################

locals {
  node_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy",
    aws_iam_policy.custom_worker.arn
  ]
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "custom_worker_policy" {
  statement {
    effect = "Allow"
    actions = [
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "autoscaling:*",
      "cloudformation:*",
      "elasticloadbalancing:*",
      "elasticloadbalancingv2:*",
      "ec2:DescribeInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeRouteTables",
      "ec2:DescribeVpcs",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:AssumeRoleWithWebIdentity",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "node" {
  name = "${local.cluster_name}-node-cluster"

  assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json
}

resource "aws_iam_policy" "custom_worker" {
  name = "${local.cluster_name}-custom-worker"

  policy = data.aws_iam_policy_document.custom_worker_policy.json
}

resource "aws_iam_role_policy_attachment" "node_policy_attachments" {
  count      = length(local.node_policy_arns)
  policy_arn = local.node_policy_arns[count.index]
  role       = aws_iam_role.node.name

  depends_on = [aws_iam_policy.custom_worker]
}

resource "aws_iam_instance_profile" "node" {
  name = "${local.cluster_name}-node-cluster-profile"
  role = aws_iam_role.node.name
}
