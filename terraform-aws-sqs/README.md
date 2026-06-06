# AWS SQS Terraform module

Terraform module which creates SQS resources on AWS.

This module will create the following components:

- A main queue for receiving messages
- A dead letter queue for storing un-processed messages

## Usage

### Create SQS

```hcl
module "sqs" {
  source  = "c0x12c/sqs/aws"
  version = "0.3.0"

  name              = "example-queue"
  max_receive_count = 1
  principal_roles   = ["arn:aws:iam::<account-id>:role/sqs-role"]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
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
| [aws_iam_policy.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.read_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_redrive_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.read_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_content_based_deduplication"></a> [content\_based\_deduplication](#input\_content\_based\_deduplication) | Max receive message count | `bool` | `false` | no |
| <a name="input_delay_seconds"></a> [delay\_seconds](#input\_delay\_seconds) | The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 | `string` | `"0"` | no |
| <a name="input_dlq_retention_seconds"></a> [dlq\_retention\_seconds](#input\_dlq\_retention\_seconds) | The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days) | `string` | `"259200"` | no |
| <a name="input_enabled_dead_letter_queue"></a> [enabled\_dead\_letter\_queue](#input\_enabled\_dead\_letter\_queue) | Enable dead letter queue | `bool` | `true` | no |
| <a name="input_enabled_dlq_queue_policy"></a> [enabled\_dlq\_queue\_policy](#input\_enabled\_dlq\_queue\_policy) | Enable dead letter queue policy | `bool` | `false` | no |
| <a name="input_enabled_kms_encryption"></a> [enabled\_kms\_encryption](#input\_enabled\_kms\_encryption) | Enable KMS encryption for the SQS queue (by default, AWS SSE-SQS is used) | `bool` | `false` | no |
| <a name="input_enabled_read_write_policy"></a> [enabled\_read\_write\_policy](#input\_enabled\_read\_write\_policy) | Enable read-write policy | `bool` | `false` | no |
| <a name="input_fifo_deduplication_scope"></a> [fifo\_deduplication\_scope](#input\_fifo\_deduplication\_scope) | Specifies whether message deduplication occurs at the message group or queue level. (perQueue or perMessageGroupId) | `string` | `null` | no |
| <a name="input_fifo_enabled"></a> [fifo\_enabled](#input\_fifo\_enabled) | Specify whether enable FIFO or not for the SQS queue | `bool` | `false` | no |
| <a name="input_fifo_throughput_limit"></a> [fifo\_throughput\_limit](#input\_fifo\_throughput\_limit) | Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group (perQueue or perMessageGroupId) | `string` | `null` | no |
| <a name="input_kms_config"></a> [kms\_config](#input\_kms\_config) | KMS configuration for the SQS queue | <pre>object({<br/>    kms_master_key_id                 = string<br/>    kms_data_key_reuse_period_seconds = number<br/>  })</pre> | <pre>{<br/>  "kms_data_key_reuse_period_seconds": 300,<br/>  "kms_master_key_id": "alias/aws/sqs"<br/>}</pre> | no |
| <a name="input_max_receive_count"></a> [max\_receive\_count](#input\_max\_receive\_count) | Max receive message count | `number` | `3` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The limit of how many bytes a message can contain before Amazon SQS rejects it | `string` | `"2048"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name for creating queue names | `string` | n/a | yes |
| <a name="input_principal_roles"></a> [principal\_roles](#input\_principal\_roles) | A list of IAM roles that a specific principal (user, service, or account) can assume. | `list(string)` | `null` | no |
| <a name="input_read_policy_name"></a> [read\_policy\_name](#input\_read\_policy\_name) | The name of the custom read policy | `string` | `null` | no |
| <a name="input_read_write_policy_name"></a> [read\_write\_policy\_name](#input\_read\_write\_policy\_name) | Custom name for the read-write policy | `string` | `null` | no |
| <a name="input_retention_seconds"></a> [retention\_seconds](#input\_retention\_seconds) | The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days) | `string` | `"86400"` | no |
| <a name="input_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | The visibility timeout for the queue. An integer from 0 to 43200 | `string` | `"30"` | no |
| <a name="input_wait_seconds"></a> [wait\_seconds](#input\_wait\_seconds) | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning | `string` | `"10"` | no |
| <a name="input_write_policy_name"></a> [write\_policy\_name](#input\_write\_policy\_name) | The name of the custom write policy | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dlq"></a> [dlq](#output\_dlq) | The SQS dead letter queue info |
| <a name="output_iam_policy_sqs_read_arn"></a> [iam\_policy\_sqs\_read\_arn](#output\_iam\_policy\_sqs\_read\_arn) | n/a |
| <a name="output_iam_policy_sqs_read_write_arn"></a> [iam\_policy\_sqs\_read\_write\_arn](#output\_iam\_policy\_sqs\_read\_write\_arn) | The ARN of the IAM policy for read-write access to the SQS queue |
| <a name="output_iam_policy_sqs_write_arn"></a> [iam\_policy\_sqs\_write\_arn](#output\_iam\_policy\_sqs\_write\_arn) | n/a |
| <a name="output_queue"></a> [queue](#output\_queue) | The SQS queue info |
<!-- END_TF_DOCS -->
