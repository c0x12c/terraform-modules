############################################
# Conditional Default Security Groups
############################################

resource "aws_security_group" "allow_all" {
  count = var.create_default_security_group ? 1 : 0

  name        = "allow_all"
  description = var.custom_sg_allow_all_description != null ? var.custom_sg_allow_all_description : "Allow all inbound and outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_all_within_vpc" {
  count = var.create_default_security_group ? 1 : 0

  name        = "allow_all_within_vpc"
  description = var.custom_sg_allow_all_within_vpc_description != null ? var.custom_sg_allow_all_within_vpc_description : "Allow all traffic within the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.cidr_blocks
    ipv6_cidr_blocks = var.ipv6_cidr_blocks
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = var.custom_sg_allow_all_within_vpc_egress_ipv6_cidr_blocks
  }
}

############################################
# Custom Security Groups and Rules
############################################

resource "aws_security_group" "this" {
  for_each = var.create_default_security_group ? {} : { for sg in var.security_groups : sg.name => sg }

  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id
  tags        = each.value.tags
}

############################################
# Security Group Rules
############################################
locals {
  ingress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for rule_key, rule in sg.ingress_rules : {
        security_group_name = sg_key
        rule_key            = rule_key
        from_port           = rule.from_port
        to_port             = rule.to_port
        ip_protocol         = rule.protocol
        cidr_ipv4           = rule.cidr_ipv4
        cidr_ipv6           = rule.cidr_ipv6
        self                = rule.self
        description         = rule.description
      }
    ]
  ])

  egress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for rule_key, rule in sg.egress_rules : {
        security_group_name = sg_key
        rule_key            = rule_key
        from_port           = rule.from_port
        to_port             = rule.to_port
        ip_protocol         = rule.protocol
        cidr_ipv4           = rule.cidr_ipv4
        cidr_ipv6           = rule.cidr_ipv6
        self                = rule.self
        description         = rule.description
      }
    ]
  ])
}

############################################
# Ingress Rules - IPv4 CIDR Blocks
############################################
resource "aws_vpc_security_group_ingress_rule" "ingress_ipv4" {
  for_each = var.create_default_security_group ? {} : tomap({
    for rule in local.ingress_rules :
    "${rule.security_group_name}_${rule.rule_key}" => rule
    if rule.cidr_ipv4 != null
  })

  security_group_id = aws_security_group.this[each.value.security_group_name].id

  from_port   = each.value.ip_protocol == "-1" ? -1 : each.value.from_port
  to_port     = each.value.ip_protocol == "-1" ? -1 : each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
  description = each.value.description
}

############################################
# Ingress Rules - IPv6 CIDR Blocks
############################################
resource "aws_vpc_security_group_ingress_rule" "ingress_ipv6" {
  for_each = var.create_default_security_group ? {} : tomap({
    for rule in local.ingress_rules :
    "${rule.security_group_name}_${rule.rule_key}" => rule
    if rule.cidr_ipv6 != null
  })

  security_group_id = aws_security_group.this[each.value.security_group_name].id

  from_port   = each.value.ip_protocol == "-1" ? -1 : each.value.from_port
  to_port     = each.value.ip_protocol == "-1" ? -1 : each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv6   = each.value.cidr_ipv6
  description = each.value.description
}

############################################
# Ingress Rules - Self
############################################
resource "aws_security_group_rule" "ingress_self" {
  for_each = var.create_default_security_group ? {} : tomap({
    for rule in local.ingress_rules :
    "${rule.security_group_name}_${rule.rule_key}" => rule
    if rule.self == true
  })

  security_group_id        = aws_security_group.this[each.value.security_group_name].id
  source_security_group_id = aws_security_group.this[each.value.security_group_name].id
  type                     = "ingress"

  protocol    = each.value.ip_protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  description = each.value.description
}

############################################
# Egress Rules - IPv4 CIDR Blocks
############################################
resource "aws_vpc_security_group_egress_rule" "egress_ipv4" {
  for_each = var.create_default_security_group ? {} : tomap({
    for rule in local.egress_rules :
    "${rule.security_group_name}_${rule.rule_key}" => rule
    if rule.cidr_ipv4 != null
  })

  security_group_id = aws_security_group.this[each.value.security_group_name].id

  from_port   = each.value.ip_protocol == "-1" ? -1 : each.value.from_port
  to_port     = each.value.ip_protocol == "-1" ? -1 : each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
  description = each.value.description
}

############################################
# Egress Rules - IPv6 CIDR Blocks
############################################
resource "aws_vpc_security_group_egress_rule" "egress_ipv6" {
  for_each = var.create_default_security_group ? {} : tomap({
    for rule in local.egress_rules :
    "${rule.security_group_name}_${rule.rule_key}" => rule
    if rule.cidr_ipv6 != null
  })

  security_group_id = aws_security_group.this[each.value.security_group_name].id

  from_port   = each.value.ip_protocol == "-1" ? -1 : each.value.from_port
  to_port     = each.value.ip_protocol == "-1" ? -1 : each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv6   = each.value.cidr_ipv6
  description = each.value.description
}

############################################
# Egress Rules - Self
############################################
resource "aws_security_group_rule" "egress_self" {
  for_each = var.create_default_security_group ? {} : tomap({
    for rule in local.egress_rules :
    "${rule.security_group_name}_${rule.rule_key}" => rule
    if rule.self == true
  })

  security_group_id        = aws_security_group.this[each.value.security_group_name].id
  source_security_group_id = aws_security_group.this[each.value.security_group_name].id
  type                     = "egress"

  protocol    = each.value.ip_protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  description = each.value.description
}
