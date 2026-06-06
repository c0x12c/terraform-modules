# External AWS CloudTrail Terraform module

Terraform module which creates external AWS CloudTrail resources:

- A CloudTrail to log API activity and events across your AWS account.
- An S3 bucket to store CloudTrail logs with appropriate policies.
- A CloudWatch Logs group to store and monitor CloudTrail logs.
- Optional SNS topic to notify on specific CloudTrail events.

## Usage

### Cloudtrail

```hcl
module "cloudtrail" {
  source = "github.com/spartan-stratos/terraform-modules//aws/cloudtrail?ref=v0.1.15"

  name                          = "example-cloudtrail"
  enable_logging                = true
  include_global_service_events = true
}

```

## Examples

- [Example](./examples/complete).

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

| Name                                                                                                                                                | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail)                                       | resource    |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                   | resource    |
| [aws_iam_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                 | resource    |
| [aws_iam_role.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                     | resource    |
| [aws_iam_role_policy_attachment.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)    | resource    |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                         | resource    |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                           | resource    |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource    |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                   | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                       | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                  | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                   | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                         | data source |

## Inputs

| Name                                                                                                                            | Description                                                                                                                                                  | Type                                                                                                                                                                                                                                    | Default      | Required |
|---------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls)                                       | Whether Amazon S3 should block public ACLs for this bucket.                                                                                                  | `bool`                                                                                                                                                                                                                                  | `true`       |    no    |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy)                                 | Whether Amazon S3 should block public bucket policies for this bucket.                                                                                       | `bool`                                                                                                                                                                                                                                  | `true`       |    no    |
| <a name="input_cloud_watch_logs_group_arn"></a> [cloud\_watch\_logs\_group\_arn](#input\_cloud\_watch\_logs\_group\_arn)        | Specifies a log group name using an Amazon Resource Name (ARN), that represents the log group to which CloudTrail logs will be delivered                     | `string`                                                                                                                                                                                                                                | `null`       |    no    |
| <a name="input_cloud_watch_logs_role_arn"></a> [cloud\_watch\_logs\_role\_arn](#input\_cloud\_watch\_logs\_role\_arn)           | Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group                                                                 | `string`                                                                                                                                                                                                                                | `null`       |    no    |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group)       | Whether to create CloudWatch log group to deliver CloudTrail logs to.                                                                                        | `bool`                                                                                                                                                                                                                                  | `false`      |    no    |
| <a name="input_disabled_s3_http_access"></a> [disabled\_s3\_http\_access](#input\_disabled\_s3\_http\_access)                   | Whether to restrict HTTP access to S3 bucket.                                                                                                                | `bool`                                                                                                                                                                                                                                  | `true`       |    no    |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation)          | Specifies whether log file integrity validation is enabled. Creates signed digest for validated contents of logs                                             | `bool`                                                                                                                                                                                                                                  | `false`      |    no    |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging)                                                  | Enable logging for the trail                                                                                                                                 | `bool`                                                                                                                                                                                                                                  | `false`      |    no    |
| <a name="input_event_selector"></a> [event\_selector](#input\_event\_selector)                                                  | Specifies an event selector for enabling data event logging. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this variable | <pre>list(object({<br/>    include_management_events = bool<br/>    read_write_type           = string<br/><br/>    data_resource = list(object({<br/>      type   = string<br/>      values = list(string)<br/>    }))<br/>  }))</pre> | `[]`         |    no    |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls)                                    | Whether Amazon S3 should ignore public ACLs for this bucket.                                                                                                 | `bool`                                                                                                                                                                                                                                  | `true`       |    no    |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Specifies whether the trail is publishing events from global services such as IAM to the log files                                                           | `bool`                                                                                                                                                                                                                                  | `false`      |    no    |
| <a name="input_insight_selector"></a> [insight\_selector](#input\_insight\_selector)                                            | Specifies an insight selector for type of insights to log on a trail                                                                                         | <pre>list(object({<br/>    insight_type = string<br/>  }))</pre>                                                                                                                                                                        | `[]`         |    no    |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail)                         | Specifies whether the trail is created in the current region or in all regions                                                                               | `bool`                                                                                                                                                                                                                                  | `false`      |    no    |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail)                           | The trail is an AWS Organizations trail                                                                                                                      | `bool`                                                                                                                                                                                                                                  | `false`      |    no    |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn)                                                         | Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail                                                                                 | `string`                                                                                                                                                                                                                                | `null`       |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                  | A friendly name of the CloudTrail.                                                                                                                           | `string`                                                                                                                                                                                                                                | n/a          |   yes    |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets)                     | Whether Amazon S3 should restrict public bucket policies for this bucket.                                                                                    | `bool`                                                                                                                                                                                                                                  | `true`       |    no    |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix)                                                   | Prefix for S3 bucket used by Cloudtrail to store logs                                                                                                        | `string`                                                                                                                                                                                                                                | `null`       |    no    |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name)                                                | Specifies the name of the Amazon SNS topic defined for notification of log file delivery                                                                     | `string`                                                                                                                                                                                                                                | `null`       |    no    |
| <a name="input_versioning_status"></a> [versioning\_status](#input\_versioning\_status)                                         | The status of bucket versioning.                                                                                                                             | `string`                                                                                                                                                                                                                                | `"Disabled"` |    no    |

## Outputs

| Name                                                                                                      | Description                      |
|-----------------------------------------------------------------------------------------------------------|----------------------------------|
| <a name="output_arn"></a> [arn](#output\_arn)                                                             | The ARN of the Cloudtrail.       |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn)                           | The ARN of the S3 bucket         |
| <a name="output_s3_bucket_domain_name"></a> [s3\_bucket\_domain\_name](#output\_s3\_bucket\_domain\_name) | The domain name of the S3 bucket |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id)                              | The name of the S3 bucket        |

<!-- END_TF_DOCS -->