# CloudFlare CloudWatch DNS CACHE Terraform module

Terraform module which creates Amazon CloudWatch Alarm resources.

## Required Permissions

This module requires a Personal API Token (Account-scoped token hasn't supported yet) with permissions:

- DNS Settings:Read
- DNS Settings:Edit
- DNS:Read
- DNS:Edit
- Page Rules:Read
- Page Rules:Edit

## Usage

```hcl

provider "cloudflare" {
  api_token = local.api_token
}

module "cloudflare_cdn_for_static_site" {
  source  = "c0x12c/record-with-cache-rule/cloudflare"
  version = "~> 1.0.0"

  zone_id = local.cloudflare_zone_id

  name         = "img.${local.cloudflare_domain}"
  record_content = module.bucket_photos_load_balancer.ip_address
  enabled_proxy      = true
  comment      = "CDN of static site"

  page_rule_actions = {
    cache_level       = "cache_everything"
    edge_cache_ttl    = 2419200
    browser_cache_ttl = 31536000
  }
}
```

## Examples

- [Example complete](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_page_rule.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/page_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cache_status"></a> [cache\_status](#input\_cache\_status) | The status of the page rule for caching. | `string` | `"active"` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Optional comment for the DNS record. | `string` | `null` | no |
| <a name="input_enabled_proxy"></a> [enabled\_proxy](#input\_enabled\_proxy) | Whether the record is proxied through Cloudflare. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the DNS record, such as 'example.com'. | `string` | n/a | yes |
| <a name="input_page_rule_actions"></a> [page\_rule\_actions](#input\_page\_rule\_actions) | Actions for the page rule associated with the DNS record. | `map(any)` | <pre>{<br/>  "browser_cache_ttl": 86400,<br/>  "cache_level": "cache_everything",<br/>  "edge_cache_ttl": 86400<br/>}</pre> | no |
| <a name="input_record_content"></a> [record\_content](#input\_record\_content) | The content of the DNS record, such as an IP address or CNAME target. | `string` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Optional settings for the DNS record. | `map(any)` | <pre>{<br/>  "ipv4_only": false,<br/>  "ipv6_only": false<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the DNS record. | `list(string)` | `[]` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Time to live for the DNS record. | `number` | `1` | no |
| <a name="input_type"></a> [type](#input\_type) | The type of DNS record (e.g., A, CNAME). | `string` | `"A"` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The ID of the Cloudflare zone where the DNS record will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_record_id"></a> [dns\_record\_id](#output\_dns\_record\_id) | n/a |
| <a name="output_page_rule_id"></a> [page\_rule\_id](#output\_page\_rule\_id) | n/a |

<!-- END_TF_DOCS -->