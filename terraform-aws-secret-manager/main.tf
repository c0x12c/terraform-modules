/**
Provides a resource to manage AWS Secrets Manager secret metadata.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
 */
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name = var.secret_prefix != null ? "${var.secret_prefix}-${each.key}" : each.key
}

/**
Provides a resource to manage AWS Secrets Manager secret version including its secret value.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version
 */
resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value
}
