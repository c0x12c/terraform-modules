output "saml_providers" {
  description = "The map of SAML provider arn(s) created."
  value = {
    for key, provider in aws_iam_saml_provider.this : key => provider.arn
  }
}
