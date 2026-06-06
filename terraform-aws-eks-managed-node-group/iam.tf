locals {
  iam_role_name          = coalesce(var.iam_role_name, "${var.name}-eks-node-group")
  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  iam_role_policies = {
    eks_worker_node_policy                  = "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy"
    ec2_container_registry_read_only_policy = "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly"
    ipv4_cni_policy                         = "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
    ebs_csi_policy                          = "${local.iam_role_policy_prefix}/service-role/AmazonEBSCSIDriverPolicy"
    efs_csi_policy                          = "${local.iam_role_policy_prefix}/service-role/AmazonEFSCSIDriverPolicy"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in merge(
    local.iam_role_policies,
    var.iam_role_additional_policies
  ) : k => v }

  policy_arn = each.value
  role       = aws_iam_role.this.name
}

data "aws_iam_policy_document" "role" {
  dynamic "statement" {
    for_each = var.iam_role_policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}


resource "aws_iam_role_policy" "this" {
  count = length(var.iam_role_policy_statements) > 0 ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  policy      = data.aws_iam_policy_document.role.json
  role        = aws_iam_role.this.id
}
