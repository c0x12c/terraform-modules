# AWS SendGrid Terraform module

Terraform module which creates SendGrid resources on AWS.

This module will create the following components:

- SendGrid API keys, domain authentication and link branding
- Route53 records to verify SendGrid domain, prevent email spoofing and phishing, and link branding.
- (Optional) Templates of email and version management.

## Usage

### Create SendGrid

```hcl
module "sendgrid" {
  source = "github.com/spartan-stratos/terraform-modules//aws/sendgrid?ref=v0.2.0"

  api_keys = {
    "email-sending-service" = {
      name = "Email Sending Service"
      scopes = [
        "mail.send",
        "2fa_required",
        "sender_verification_eligible"
      ]
    }
  }
  dns_zone_id   = "zone-id"
  dns_zone_name = "zone-name"
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75  |
| <a name="requirement_sendgrid"></a> [sendgrid](#requirement\_sendgrid)    | >= 1.0.5 |

## Providers

| Name                                                             | Version  |
|------------------------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)                | >= 5.75  |
| <a name="provider_sendgrid"></a> [sendgrid](#provider\_sendgrid) | >= 1.0.5 |

## Modules

No modules.

## Resources

| Name                                                                                                                                           | Type     |
|------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_route53_record.cname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                         | resource |
| [aws_route53_record.link_branding_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)         | resource |
| [aws_route53_record.txt_dmarc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                     | resource |
| [sendgrid_api_key.this](https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/api_key)                             | resource |
| [sendgrid_domain_authentication.this](https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/domain_authentication) | resource |
| [sendgrid_link_branding.this](https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/link_branding)                 | resource |
| [sendgrid_template.this](https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/template)                           | resource |
| [sendgrid_template_version.this](https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/template_version)           | resource |

## Inputs

| Name                                                                                                                                   | Description                                                                                                      | Type                                                                                                                                                                      | Default | Required |
|----------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_api_keys"></a> [api\_keys](#input\_api\_keys)                                                                           | A map of API keys with their names and associated scopes. Scopes define the permissions granted to each API key. | <pre>map(object({<br/>    name   = string<br/>    scopes = list(string) # https://docs.sendgrid.com/api-reference/api-key-permissions/api-key-permissions<br/>  }))</pre> | n/a     |   yes    |
| <a name="input_automatic_security"></a> [automatic\_security](#input\_automatic\_security)                                             | Whether to allow SendGrid to manage SPF records, DKIM keys, and DKIM key rotation automatically.                 | `bool`                                                                                                                                                                    | `true`  |    no    |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id)                                                                | The unique identifier of the DNS zone.                                                                           | `string`                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name)                                                          | The name of the DNS zone to be used for SendGrid configuration.                                                  | `string`                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_is_default_authenticated_domain"></a> [is\_default\_authenticated\_domain](#input\_is\_default\_authenticated\_domain)  | Whether to use this authenticated domain as the fallback if no authenticated domains match the sender's domain.  | `bool`                                                                                                                                                                    | `true`  |    no    |
| <a name="input_is_default_link_branding"></a> [is\_default\_link\_branding](#input\_is\_default\_link\_branding)                       | Indicates if this is the default link branding.                                                                  | `bool`                                                                                                                                                                    | `true`  |    no    |
| <a name="input_sendgrid_transactional_templates"></a> [sendgrid\_transactional\_templates](#input\_sendgrid\_transactional\_templates) | A map of SendGrid transactional email templates, each containing a subject and content.                          | <pre>map(object({<br/>    subject = string<br/>    content = string<br/>  }))</pre>                                                                                       | `{}`    |    no    |

## Outputs

| Name                                                                                         | Description |
|----------------------------------------------------------------------------------------------|-------------|
| <a name="output_api_keys"></a> [api\_keys](#output\_api\_keys)                               | n/a         |
| <a name="output_sendgrid_templates"></a> [sendgrid\_templates](#output\_sendgrid\_templates) | n/a         |

<!-- END_TF_DOCS -->
