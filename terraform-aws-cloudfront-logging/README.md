# Cloudfront logging module

## Usage

### Create V2 Cloudfront logging to S3

```hcl
module "cloudfront_logging" {
  source  = "c0x12c/cloudfront-logging/aws"
  version = "0.1.0"

  # Use provider `us-east-1`
  # Refer: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logging.html
  providers = {
    aws = aws.global
  }

  name                            = "web-platform"
  log_bucket_arn                  = module.cloudfront_log_bucket.s3_bucket_arn
  aws_cloudfront_distribution_arn = module.static_website.cloudfront_distribution_arn
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                            | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_cloudwatch_log_delivery.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery)                         | resource |
| [aws_cloudwatch_log_delivery_destination.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery_destination) | resource |
| [aws_cloudwatch_log_delivery_source.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery_source)           | resource |

## Inputs

| Name                                                                                                                                  | Description                                               | Type     | Default | Required |
|---------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|----------|---------|:--------:|
| <a name="input_aws_cloudfront_distribution_arn"></a> [aws\_cloudfront\_distribution\_arn](#input\_aws\_cloudfront\_distribution\_arn) | CloudFront distribution's arn as source to deliver logs.  | `string` | n/a     |   yes    |
| <a name="input_log_bucket_arn"></a> [log\_bucket\_arn](#input\_log\_bucket\_arn)                                                      | Log bucket's arn that used to store CloudFront logs.      | `string` | n/a     |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                                                        | For creating or retrieving the bucket and cloudfront name | `string` | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
