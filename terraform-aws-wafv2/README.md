# AWS WAFv2 Terraform module

Introduced a new module for managing AWS WAFv2 configurations.

- The module includes support for managed rules, IP-based filtering, rate-based rules, and ACL associations for
  CloudFront and ALB.
- Documentation, examples, inputs, outputs, and a changelog have been added for ease of use.

## Usage

### Create WAFv2

```hcl
module "wafv2_cloudfront" {
  providers = {
    aws = aws.global
  }

  source = "github.com/spartan-stratos/terraform-modules//aws/wafv2?ref=v0.1.72"

  name  = "cloudfront-name"
  scope = "CLOUDFRONT"
  managed_rules = [
    {
      name            = "AWSManagedRulesCommonRuleSet",
      override_action = "none",
      priority        = 1,
      vendor_name     = "AWS"
      rule_action_override = []
    }
  ]
}

module "wafv2_alb" {
  source = "github.com/spartan-stratos/terraform-modules//aws/wafv2?ref=v0.1.72"

  name  = "alb-name"
  scope = "REGIONAL"
  managed_rules = [
    {
      name            = "AWSManagedRulesCommonRuleSet",
      override_action = "none",
      priority        = 1,
      vendor_name     = "AWS"
      rule_action_override = [
        {
          name          = "SizeRestrictions_BODY"
          action_to_use = "allow"
        }
      ]
    }
  ]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.87.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.87.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | Whether the associated resource sends metrics to CloudWatch. | `bool` | `false` | no |
| <a name="input_enabled_wafv2_web_acl_association"></a> [enabled\_wafv2\_web\_acl\_association](#input\_enabled\_wafv2\_web\_acl\_association) | Specifies whether to enable the association of the WAFv2 Web ACL with a resource. | `bool` | `false` | no |
| <a name="input_excluded_paths"></a> [excluded\_paths](#input\_excluded\_paths) | A rule to exclude a single path from being evaluated by the WAF | `list(string)` | `[]` | no |
| <a name="input_filtered_header_rule"></a> [filtered\_header\_rule](#input\_filtered\_header\_rule) | HTTP header to filter . Currently supports a single header type and multiple header values. | <pre>object({<br/>    header_types  = list(string)<br/>    priority      = number<br/>    header_value  = string<br/>    action        = string<br/>    search_string = string<br/>  })</pre> | `null` | no |
| <a name="input_geo_rules"></a> [geo\_rules](#input\_geo\_rules) | List of WAFv2 geo-based rules. | <pre>list(object({<br/>    name          = string<br/>    priority      = number<br/>    action        = string                     # "count" or "block"<br/>    type          = string                     # "label_us_ca", "block_non_us_ca", or "block_state"<br/>    country_codes = optional(list(string), []) # For geo_match (e.g., ["US", "CA"])<br/>    label_keys    = optional(list(string), []) # For not_labels or label_match (e.g., ["awswaf:clientip:geo:region:US-AZ"])<br/>    response_code = optional(number, 403)<br/>  }))</pre> | `[]` | no |
| <a name="input_group_rules"></a> [group\_rules](#input\_group\_rules) | List of WAFv2 Rule Groups. | <pre>list(object({<br/>    name            = string<br/>    arn             = string<br/>    priority        = number<br/>    override_action = string<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_rate_based_rule"></a> [ip\_rate\_based\_rule](#input\_ip\_rate\_based\_rule) | A rate-based rule tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span | <pre>object({<br/>    name                  = string<br/>    priority              = number<br/>    limit                 = number<br/>    action                = string<br/>    response_code         = optional(number, 403)<br/>    evaluation_window_sec = optional(number, 300)<br/>  })</pre> | `null` | no |
| <a name="input_ip_rate_url_based_rules"></a> [ip\_rate\_url\_based\_rules](#input\_ip\_rate\_url\_based\_rules) | A rate and url based rules tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span | <pre>list(object({<br/>    name                  = string<br/>    priority              = number<br/>    limit                 = number<br/>    action                = string<br/>    response_code         = optional(number, 403)<br/>    search_string         = string<br/>    positional_constraint = string<br/>    evaluation_window_sec = optional(number, 300)<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_sets_rule"></a> [ip\_sets\_rule](#input\_ip\_sets\_rule) | A rule to detect web requests coming from particular IP addresses or address ranges. | <pre>list(object({<br/>    name          = string<br/>    priority      = number<br/>    ip_set_arn    = string<br/>    action        = string<br/>    response_code = optional(number, 403)<br/>  }))</pre> | `[]` | no |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | List of Managed WAF rules. | <pre>list(object({<br/>    name            = string<br/>    priority        = number<br/>    override_action = string<br/>    vendor_name     = string<br/>    version         = optional(string)<br/>    rule_action_override = list(object({<br/>      name          = string<br/>      action_to_use = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | A friendly name of the WebACL. | `string` | n/a | yes |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | Whether AWS WAF should store a sampling of the web requests that match the rules. | `bool` | `false` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | The scope of this Web ACL. Valid options: CLOUDFRONT, REGIONAL. | `string` | n/a | yes |
| <a name="input_web_acl_associations_arn"></a> [web\_acl\_associations\_arn](#input\_web\_acl\_associations\_arn) | A resource ARN to associate with the Web ACL. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_wafv2_arn"></a> [wafv2\_arn](#output\_wafv2\_arn) | n/a |
<!-- END_TF_DOCS -->