/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl
 */
resource "aws_network_acl" "this" {
  count = var.custom_acls != null ? 1 : 0

  vpc_id     = aws_vpc.this.id
  subnet_ids = flatten([aws_subnet.public.*.id, aws_subnet.private.*.id])
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
 */
resource "aws_network_acl_rule" "this" {
  for_each = var.custom_acls != null ? var.custom_acls : {}

  network_acl_id = aws_network_acl.this[0].id
  rule_number    = each.value.rule_number
  cidr_block     = each.value.cidr_block
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  egress         = each.value.egress
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  icmp_type      = each.value.icmp_type
  icmp_code      = each.value.icmp_code
}
