# AWS Cloudfront Terraform sub-module

Terraform sub-module which creates Cloudfront resources on AWS.

## Usage

### Create Cloudfront

```hcl
module "cloudfront" {
  source = "github.com/spartan-stratos/terraform-modules//aws/static-website/aws//modules/cloudfront"

  dns_name           = var.dns_name
  route53_zone_id     = var.route53_zone_id
  route53_zone_name   = var.route53_zone_name
  s3_bucket_id        = module.s3.s3_bucket_id
  ssl_certificate_arn = var.global_tls_certificate_arn
  response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
  
  ordered_cache_behaviors = [{
    path_pattern           = "/index.html"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "s3_origin_id"
    query_string           = false
    cookies_forward        = "none"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }]
}
```

## Examples

- [Example](../../examples/complete/)

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

| Name                                                                                                                                                                             | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)                                          | resource    |
| [aws_cloudfront_origin_access_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control)                        | resource    |
| [aws_cloudfront_response_headers_policy ](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy#content-type-options)   | resource    |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                                            | resource    |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                                             | resource    |
| [aws_s3_bucket_policy.react_app_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                     | resource    |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                               | data source |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket)                                                                   | data source |

## Inputs

| Name                                                                                                      | Description                                              | Type                                                                 | Default                                                                                                        | Required |
|-----------------------------------------------------------------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|:--------:|
| <a name="input_distribution_aliases"></a> [distribution\_aliases](#input\_distribution\_aliases)          | List of domain names that associate with the CloudFront distribution. | list(string)                                                         | null                                                                                                           | no       |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name)                                              | The DNS name for the static website                      | string                                                               | n/a                                                                                                            | yes      |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name)                                     | The domain name for the static website.                  | string                                                               | n/a                                                                                                            | yes      |
| <a name="input_minimum_protocol_version"></a> [minimum\_protocol\_version](#input\_minimum\_protocol\_version) | The minimum version of the SSL protocol for HTTPS       | string                                                               | "TLSv1.2_2021"                                                                                                | no       |
| <a name="input_ordered_cache_behaviors"></a> [ordered\_cache\_behaviors](#input\_ordered\_cache\_behaviors) | List of ordered cache behaviors with path patterns      | list(object({...}))                                                  | []                                                                                                             | no       |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class)                                     | The price class for this distribution                    | string                                                               | "PriceClass_100"                                                                                               | no       |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id)                       | Route53 zone id                                          | string                                                               | n/a                                                                                                            | yes      |
| <a name="input_s3_bucket_id"></a> [s3\_bucket\_id](#input\_s3\_bucket\_id)                                | The origin S3 bucket id                                  | string                                                               | n/a                                                                                                            | yes      |
| <a name="input_ssl_certificate_arn"></a> [ssl\_certificate\_arn](#input\_ssl\_certificate\_arn)           | SSL certificate ARN for CloudFront distribution         | string                                                               | n/a                                                                                                            | yes      |
| <a name="input_use_www_domain"></a> [use\_www\_domain](#input\_use\_www\_domain)                          | Use www domain                                          | bool                                                                 | false                                                                                                          | no       |
| <a name="input_viewer_protocol_policy"></a> [viewer\_protocol\_policy](#input\_viewer\_protocol\_policy)  | Determines protocols viewers can use                     | string                                                               | "redirect-to-https"                                                                                            | no       |
| <a name="input_enabled_response_headers_policy"></a> [enabled\_response\_headers\_policy](#input\_enabled\_response\_headers\_policy) | Enable response headers policy configuration | bool                                                                 | false                                                                                                          | no       |
| <a name="input_referrer_policy"></a> [referrer\_policy](#input\_referrer\_policy)                         | Referrer Policy settings                                | object({ override = bool, referrer_policy = string })                | { override = true, referrer_policy = "strict-origin-when-cross-origin" }                                      | no       |
| <a name="input_content_security_policy"></a> [content\_security\_policy](#input\_content\_security\_policy) | Content Security Policy settings                        | object({ override = bool, content_security_policy = string })         | { override = true, content_security_policy = "default-src 'self'; object-src 'none'; script-src 'self' ..." } | no       |
| <a name="input_strict_transport_security"></a> [strict\_transport\_security](#input\_strict\_transport\_security) | Strict Transport Security settings                      | object({ override = bool, access_control_max_age_sec = number, include_subdomains = bool, preload = bool }) | { override = true, access_control_max_age_sec = 63072000, include_subdomains = true, preload = true }         | no       |
| <a name="input_content_type_options"></a> [content\_type\_options](#input\_content\_type\_options)        | Content Type Options settings                           | object({ override = bool })                                          | { override = true }                                                                                            | no       |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | The Cloudfront ID that hosting the web |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
<!-- END_TF_DOCS -->
