# AWS SES Terraform module

Terraform module which creates SES resources on AWS.

This module will create the following components:

- SES
- (Optional) Route53 record to verify SES domain

## Usage

### Create SES

```hcl
module "ses" {
  source  = "c0x12c/ses/aws"
  version = "1.0.0"

  environment  = "dev"
  email_domain = "example1.com"

  emails = ["abc@example1.com", "xyz@example1.com"]

  principal_roles = ["arn:aws:iam::<account-id>:role/ses-role"]

  iam_role_ids = ["arn:aws:iam::<account-id>:role/ses-role"]

  verify_domain = true
  record_ttl    = 600
  record_type   = "TXT"

  enabled_outgoing_email_logs           = false
  datadog_api_key                       = null
  datadog_site                          = null
  enabled_datadog_dashboard             = true
  datadog_dashboard_default_environment = "dev"
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.mx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.verification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ses_domain_dkim.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim) | resource |
| [aws_ses_domain_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity) | resource |
| [aws_ses_domain_identity_verification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity_verification) | resource |
| [aws_ses_email_identity.emails](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_email_identity) | resource |
| [aws_ses_identity_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_identity_policy) | resource |
| [aws_iam_policy_document.identity_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_email_domain"></a> [email\_domain](#input\_email\_domain) | The domain name for which SES will be configured (e.g., 'example.com'). | `string` | n/a | yes |
| <a name="input_email_receiving_endpoint"></a> [email\_receiving\_endpoint](#input\_email\_receiving\_endpoint) | The SMTP endpoint used for receiving emails. This is typically the inbound email receiving endpoint for Amazon SES in the specified region, such as 'inbound-smtp.us-west-2.amazonaws.com'. Update this if using a custom or alternative email receiving service. | `string` | `"inbound-smtp.us-west-2.amazonaws.com"` | no |
| <a name="input_emails"></a> [emails](#input\_emails) | List of email addresses allowed for sending in SES sandbox mode. These are verified to send emails during testing. | `list(string)` | `[]` | no |
| <a name="input_enabled_ses_identity_policy"></a> [enabled\_ses\_identity\_policy](#input\_enabled\_ses\_identity\_policy) | Whether to enable the SES identity policy. | `bool` | `true` | no |
| <a name="input_iam_role_ids"></a> [iam\_role\_ids](#input\_iam\_role\_ids) | List of IAM role ids that should have access to SES. These roles will have permissions to send SES email. | `list(string)` | `[]` | no |
| <a name="input_principal_roles"></a> [principal\_roles](#input\_principal\_roles) | List of IAM principal roles that should have access to SES. | `list(string)` | `null` | no |
| <a name="input_publish_dkim_record"></a> [publish\_dkim\_record](#input\_publish\_dkim\_record) | Publish the DKIM (DomainKeys Identified Mail) records signing for outgoing emails. | `bool` | `false` | no |
| <a name="input_publish_mx_record"></a> [publish\_mx\_record](#input\_publish\_mx\_record) | Publish an MX record for Amazon SES email receiving. | `bool` | `false` | no |
| <a name="input_record_ttl"></a> [record\_ttl](#input\_record\_ttl) | The TTL of the record. | `number` | `600` | no |
| <a name="input_record_type"></a> [record\_type](#input\_record\_type) | The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT. | `string` | `"TXT"` | no |
| <a name="input_verify_domain"></a> [verify\_domain](#input\_verify\_domain) | To enable route53 record to verify email domain | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_identity_arn"></a> [domain\_identity\_arn](#output\_domain\_identity\_arn) | The ARN of the SES domain identity. |
| <a name="output_domain_identity_id"></a> [domain\_identity\_id](#output\_domain\_identity\_id) | n/a |
| <a name="output_email_identity_ids"></a> [email\_identity\_ids](#output\_email\_identity\_ids) | n/a |
| <a name="output_iam_policy_ses_send_email"></a> [iam\_policy\_ses\_send\_email](#output\_iam\_policy\_ses\_send\_email) | n/a |
<!-- END_TF_DOCS -->
