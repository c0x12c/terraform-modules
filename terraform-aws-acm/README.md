# AWS Certificate Manager (ACM) Terraform module

Terraform module which creates ACM certificates and validates them using Route53 DNS.

## Usage

### ACM

```hcl
module "acm" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/acm?ref=v0.1.62"

  zone_id                   = "example"
  domain_name               = "example.com"
  subject_alternative_names = [
    "*.example.com"
  ]

  wait_for_validation = false

  tags = {
    Name = "example.com"
  }
}
```

## Examples

- [Example with DNS validation](./examples/dns-validation/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | \>= 5.75 |

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | \>= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                                          | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate)                       | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                   | resource |

## Inputs

| Name                                                                                                              | Description                                                                            | Type           | Default | Required |
|-------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name)                                             | A domain name for which the certificate should be issued                               | `string`       | n/a     |   yes    |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | A list of domains that should be SANs in the issued certificate                        | `list(string)` | `[]`    |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                    | A mapping of tags to assign to the resource                                            | `map(string)`  | `{}`    |    no    |
| <a name="input_validation_timeout"></a> [validation\_timeout](#input\_validation\_timeout)                        | Define maximum timeout to wait for the validation to complete                          | `string`       | `"10m"` |    no    |
| <a name="input_wait_for_validation"></a> [wait\_for\_validation](#input\_wait\_for\_validation)                   | Whether to wait for the validation to complete                                         | `bool`         | `true`  |    no    |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id)                                                         | The ID of the hosted zone to contain this record. Required when validating via Route53 | `string`       | n/a     |   yes    |

## Outputs

| Name                                                                                                                                                                    | Description                                                                                                                                                                          |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn)                                                                       | The ARN of the certificate                                                                                                                                                           |
| <a name="output_acm_certificate_domain_validation_options"></a> [acm\_certificate\_domain\_validation\_options](#output\_acm\_certificate\_domain\_validation\_options) | A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used. |
| <a name="output_acm_certificate_status"></a> [acm\_certificate\_status](#output\_acm\_certificate\_status)                                                              | Status of the certificate.                                                                                                                                                           |

<!-- END_TF_DOCS -->
