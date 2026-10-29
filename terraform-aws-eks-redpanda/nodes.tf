# Dedicated broker nodes: one managed node group per subnet, so each AZ scales on its own and a
# broker's node never moves zones. Brokers need one node each (the chart's anti-affinity is hard
# on hostname), so each group holds ceil(replicas / AZs) nodes plus one spare for replacements.
data "aws_subnet" "broker" {
  for_each = var.node_group.create ? toset(var.node_group.subnet_ids) : toset([])
  id       = each.value
}

data "cloudinit_config" "broker" {
  count = var.node_group.create ? 1 : 0

  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/userdata/redpanda-node.yaml.tftpl")
  }
}

resource "aws_launch_template" "broker" {
  count = var.node_group.create ? 1 : 0

  name_prefix = "${local.aws_name}-"
  user_data   = data.cloudinit_config.broker[0].rendered

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.node_group.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = local.aws_name })
  }

  tags = var.tags
}

resource "aws_eks_node_group" "this" {
  for_each = data.aws_subnet.broker

  cluster_name    = var.eks_cluster_name
  node_group_name = "${var.name}-${each.value.availability_zone}"
  node_role_arn   = aws_iam_role.node[0].arn
  subnet_ids      = [each.value.id]
  version         = var.node_group.kubernetes_version
  ami_type        = can(regex("^[a-z]+[0-9]+g", local.brokers.instance_types[0])) ? "AL2023_ARM_64_STANDARD" : "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND" # Spot reclaims would take brokers down together.
  instance_types  = local.brokers.instance_types
  labels          = local.node_label

  scaling_config {
    desired_size = ceil(local.brokers.replicas / length(var.node_group.subnet_ids))
    min_size     = ceil(local.brokers.replicas / length(var.node_group.subnet_ids))
    max_size     = ceil(local.brokers.replicas / length(var.node_group.subnet_ids)) + 1
  }

  update_config {
    max_unavailable = 1
  }

  taint {
    key    = local.node_taint.key
    value  = local.node_taint.value
    effect = "NO_SCHEDULE"
  }

  launch_template {
    id      = aws_launch_template.broker[0].id
    version = aws_launch_template.broker[0].latest_version
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.node]
}
