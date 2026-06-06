/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
 */
data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.image_distro}-${var.image_version}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["136693071363"] # AWS
}
