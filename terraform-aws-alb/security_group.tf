/*
aws_security_group provides a security group resource that allow inbound traffic only on port 80 and 443.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
*/
resource "aws_security_group" "alb" {
  name   = "${var.name}-sg-alb"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.enabled_http_port ? [1] : []
    content {
      protocol         = "tcp"
      from_port        = 80
      to_port          = 80
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({
    Name = "${var.name}-sg-alb"
  }, var.tags)
}
