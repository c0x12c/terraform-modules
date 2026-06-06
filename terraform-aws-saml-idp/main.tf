/**
`aws_iam_saml_provider` provisions an IAM SAML provider.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider
 */
resource "aws_iam_saml_provider" "this" {
  for_each = var.saml_providers

  name                   = each.key
  saml_metadata_document = base64decode(each.value)
}
