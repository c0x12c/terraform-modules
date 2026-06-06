# AWS Route53 Terraform module

Terraform module which creates Route53 resources on AWS.

This module will create the following components:

- Route53 hosted zone with provided zone name

## Usage

### Create Route53

```hcl
module "route53" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/route53?ref=v0.1.0"

  dns_zone = "example.com"

  create_new = true

  custom_records = {
    "web-app" = {
      type    = "CNAME"
      ttl     = 300
      records = ["alias"]
    }
  }
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

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | \>= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                     | Type        |
|--------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)    | resource    |
| [aws_route53_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)    | resource    |
| [aws_route53_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name                                                                           | Description                                                                                  | Type                                                                                                                                                                                                         | Default | Required |
|--------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_create_new"></a> [create\_new](#input\_create\_new)             | Flag to determine if new resources should be created                                         | `bool`                                                                                                                                                                                                       | `false` |    no    |
| <a name="input_custom_records"></a> [custom\_records](#input\_custom\_records) | Custom DNS records for Route 53 configuration, with options for type, TTL, and record values | <pre>map(object({<br/>    zone_id = optional(string)<br/>    type    = optional(string) // default: CNAME<br/>    ttl     = optional(number) // default: 3600<br/>    records = list(string)<br/>  }))</pre> | `{}`    |    no    |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone)                   | The DNS zone name for Route 53 configuration                                                 | `string`                                                                                                                                                                                                     | n/a     |   yes    |

## Outputs

| Name                                                                                                      | Description                                                                   |
|-----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| <a name="output_first_record_fqdn"></a> [first\_record\_fqdn](#output\_first\_record\_fqdn)               | Fully qualified domain name (FQDN) of the first Route 53 record, if available |
| <a name="output_r53_main_name_servers"></a> [r53\_main\_name\_servers](#output\_r53\_main\_name\_servers) | A list of name servers in associated (or default) delegation set.             |
| <a name="output_r53_main_zone_id"></a> [r53\_main\_zone\_id](#output\_r53\_main\_zone\_id)                | The unique identifier of the main Route 53 DNS zone                           |
| <a name="output_r53_main_zone_name"></a> [r53\_main\_zone\_name](#output\_r53\_main\_zone\_name)          | The DNS name of the main Route 53 zone                                        |

<!-- END_TF_DOCS -->