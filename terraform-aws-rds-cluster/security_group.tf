resource "aws_security_group" "this" {
  name        = "${var.name}-cluster"
  description = "Cluster security group for ${var.name}"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all egress"
  tags              = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "from_sg" {
  for_each = {
    for k, v in var.security_group_rules : k => v
    if v.source_security_group_id != null
  }

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value.source_security_group_id
  from_port                    = coalesce(each.value.from_port, local.port)
  to_port                      = coalesce(each.value.to_port, local.port)
  ip_protocol                  = "tcp"
  description                  = coalesce(each.value.description, "Ingress from ${each.key}")
  tags                         = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr" {
  for_each = merge([
    for k, v in var.security_group_rules : {
      for cidr in coalesce(v.cidr_blocks, []) :
      "${k}-${replace(cidr, "/", "_")}" => {
        rule_key    = k
        cidr        = cidr
        from_port   = v.from_port
        to_port     = v.to_port
        description = v.description
      }
    }
  ]...)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value.cidr
  from_port         = coalesce(each.value.from_port, local.port)
  to_port           = coalesce(each.value.to_port, local.port)
  ip_protocol       = "tcp"
  description       = coalesce(each.value.description, "Ingress from ${each.value.rule_key} (${each.value.cidr})")
  tags              = var.tags
}
