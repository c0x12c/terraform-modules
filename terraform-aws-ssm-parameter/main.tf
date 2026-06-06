/*
aws_ssm_parameter creates or updates parameters in AWS Systems Manager Parameter Store.
The parameter name, type, and security settings are dynamically generated based on provided input, 
supporting both secure and insecure values, and single or list values.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
*/
resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name        = "/${var.prefix}/${each.key}"
  type        = !each.value.insecure ? "SecureString" : length(each.value.values) > 0 ? "StringList" : "String"
  description = each.value.description

  value          = !each.value.insecure ? length(each.value.values) > 0 ? jsonencode(each.value.values) : each.value.value : null
  insecure_value = each.value.insecure ? length(each.value.values) > 0 ? jsonencode(each.value.values) : each.value.value : null

  tier            = each.value.tier
  key_id          = each.value.key_id
  allowed_pattern = each.value.allowed_pattern
  data_type       = each.value.data_type
}
