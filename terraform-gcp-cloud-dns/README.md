# GCP DNS record Terraform module

Terraform module which creates Cloud DNS resources on GCP.

This module will create the following components:

- DNS managed zone with provided zone name and DNS name.
- DNS records name with provided type, ttl, and rrdatas.

## Usage

### Create Cloud DNS

```hcl
module "cloud_dns" {
  source  = "terraform.c0x12c.com/c0x12c/cloud-dns/gcp"
  version = "0.1.4"

  create_new = true

  dns_zone    = "example-com"
  dns_name    = "example.com."
  description = "DNS zone for domain: example.com"
  visibility  = "public"

  custom_records = {
    "web-app" = {
      type    = "CNAME"
      ttl     = 300
      rrdatas = ["alias"]
    }
  }
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_dns_managed_zone.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_managed_zone.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_new"></a> [create\_new](#input\_create\_new) | Flag to determine if new resources should be created. | `bool` | `false` | no |
| <a name="input_custom_records"></a> [custom\_records](#input\_custom\_records) | Custom DNS records within Google Cloud DNS. | <pre>map(object({<br/>    type    = optional(string) // default: CNAME<br/>    ttl     = optional(number) // default: 3600<br/>    rrdatas = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | The user-provided description of the DNS zone. | `string` | `""` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | The DNS name of a DNS managed zone. | `string` | n/a | yes |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | A DNS zone is a DNS namespace used to manage DNS records for a domain. | `string` | n/a | yes |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | The DNS zone visibility: where public zones are exposed to the Internet, while private zones are visible only to Virtual Private Cloud resources. Possible values are: private, public. | `string` | `"public"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_record_names"></a> [dns\_record\_names](#output\_dns\_record\_names) | The DNS record name list created |
<!-- END_TF_DOCS -->
