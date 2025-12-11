resource "aws_instance" "this" {
  ami                                  = var.ami
  instance_type                        = var.instance_type
  subnet_id                            = var.subnet_id
  vpc_security_group_ids               = var.security_group_ids
  key_name                             = var.key_name
  iam_instance_profile                 = var.iam_instance_profile
  associate_public_ip_address          = var.associate_public_ip_address
  user_data                            = var.user_data
  user_data_base64                     = var.user_data_base64
  availability_zone                    = var.availability_zone
  tenancy                              = var.tenancy
  ebs_optimized                        = var.ebs_optimized
  monitoring                           = var.monitoring
  source_dest_check                    = var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []
    content {
      volume_type           = lookup(root_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(root_block_device.value, "volume_size", 20)
      iops                  = lookup(root_block_device.value, "iops", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      tags                  = lookup(root_block_device.value, "tags", {})
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(ebs_block_device.value, "volume_size", 20)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      tags                  = lookup(ebs_block_device.value, "tags", {})
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "required")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", 1)
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", "disabled")
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = network_interface.value.network_interface_id
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )

  volume_tags = var.volume_tags

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      user_data_base64
    ]
  }
}

resource "aws_eip" "this" {
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = merge(
    {
      Name = "${var.name}-eip"
    },
    var.eip_tags
  )
}
