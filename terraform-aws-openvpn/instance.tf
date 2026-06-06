/*
https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
 */
resource "random_password" "this" {
  length  = 24
  special = false
}

/*
https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
Ignore `tls_private_key` creation if you want to use existing key `ec2_public_key`.
 */
resource "tls_private_key" "management_ssh_key" {
  count     = (var.create_management_key_pair && var.ec2_public_key == null) ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

/**
Provides an EC2 key pair resource. A key pair is used to control login access to EC2 instances.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
 */
resource "aws_key_pair" "management_ssh_key" {
  count      = var.create_management_key_pair ? 1 : 0
  key_name   = var.key_name != null ? var.key_name : var.vpn_name
  public_key = var.ec2_public_key != null ? var.ec2_public_key : tls_private_key.management_ssh_key[0].public_key_openssh
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
 */
resource "aws_instance" "this" {
  count = var.replace_instance_on_update ? 0 : 1

  ami           = data.aws_ami.debian.id
  instance_type = var.instance_type
  key_name      = var.create_management_key_pair ? aws_key_pair.management_ssh_key[0].key_name : null
  subnet_id     = var.subnet_id

  vpc_security_group_ids = concat(
    var.extra_sg_ids,
    [aws_security_group.this.id],
  )

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens   = var.http_tokens
    http_endpoint = var.http_endpoint
  }

  user_data_replace_on_change = true
  user_data                   = templatefile("${path.module}/scripts/install_openvpn.sh", local.openvpn_config)

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

resource "aws_instance" "replacable" {
  count = var.replace_instance_on_update ? 1 : 0

  ami           = data.aws_ami.debian.id
  instance_type = var.instance_type
  key_name      = var.create_management_key_pair ? aws_key_pair.management_ssh_key[0].key_name : null
  subnet_id     = var.subnet_id

  vpc_security_group_ids = concat(
    var.extra_sg_ids,
    [aws_security_group.this.id],
  )

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens   = var.http_tokens
    http_endpoint = var.http_endpoint
  }

  user_data_replace_on_change = true
  user_data                   = templatefile("${path.module}/scripts/install_openvpn.sh", local.openvpn_config)

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
 */
resource "aws_eip" "this" {
  instance = var.replace_instance_on_update ? aws_instance.replacable[0].id : aws_instance.this[0].id
  domain   = "vpc"
}
