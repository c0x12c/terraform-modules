/*
`aws_kms_key` creates a KMS (Key Management Service) key in AWS.
Used here to define a customer-managed KMS key with attributes like description, usage, and custom key store details.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
*/
resource "aws_kms_key" "this" {
  description              = var.description
  deletion_window_in_days  = var.deletion_window_in_days
  key_usage                = var.key_usage
  custom_key_store_id      = var.custom_key_store_id
  customer_master_key_spec = var.customer_master_key_spec
  enable_key_rotation      = var.enable_key_rotation
}

/*
`aws_kms_alias` creates an alias for a KMS key in AWS.
Used here to assign a user-friendly name (`alias/${var.name}`) to the KMS key created by `aws_kms_key.this` for easier management and reference.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
*/


resource "aws_kms_alias" "this" {
  for_each      = toset(var.alias_name)
  name          = "alias/${each.value}"
  target_key_id = aws_kms_key.this.key_id
}
