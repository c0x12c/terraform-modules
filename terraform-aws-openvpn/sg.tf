/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
 */
resource "aws_security_group" "this" {
  name   = var.vpn_name
  vpc_id = var.vpc_id
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
 */
resource "aws_security_group_rule" "egress_vpn" {
  count             = var.create_egress_vpn_rule ? 1 : 0
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]

  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
Allow connections to OpenVPN port
 */
resource "aws_security_group_rule" "udp_vpn" {
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]

  type      = "ingress"
  from_port = "1194"
  to_port   = "1194"
  protocol  = "udp"
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
Allow Certbot TLS renewal
 */
resource "aws_security_group_rule" "http_vpn" {
  count = var.enabled_http_port ? 1 : 0

  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]

  type      = "ingress"
  from_port = "80"
  to_port   = "80"
  protocol  = "tcp"
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
Allow Google OAuth 2.0 callback
 */
resource "aws_security_group_rule" "https_vpn" {
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]

  type      = "ingress"
  from_port = "443"
  to_port   = "443"
  protocol  = "tcp"
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# Allow SSH access to VPN instances
 */
resource "aws_security_group_rule" "default_ssh_vpn" {
  count = var.allow_remote_ssh_access ? 1 : 0

  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]

  type      = "ingress"
  from_port = "22"
  to_port   = "22"
  protocol  = "tcp"
}
