# AWS Scheduler Terraform module

AWS Scheduler Terraform Module
Terraform module which creates AWS Scheduler resources using EventBridge Scheduler on AWS.

This module will create:

- AWS Scheduler schedule with configuration for running scheduled tasks.
- IAM policies and roles for Scheduler to execute the tasks (e.g., sending SQS messages).

## Usage

### Create Scheduler

```hcl
module "scheduler" {
  source  = "c0x12c/schedulers/aws"
  version = "1.1.0"

  sqs_arn                      = module.sqs-project-service-connection.queue.arn
  schedule_expression          = "cron(0 0/1 * * ? *)"
  schedule_expression_timezone = "UTC"
  message_body = jsonencode({
    type = "cronjob"
    kind = "example-payload"
  })
  queue_url = "https://sqs.<region>.amazonaws.com/<account_id>:<queue_name>"
}
```

## Examples

- [Example](./examples/complete/)

## Requirements

| Name                                                                     | Version  |
|--------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | \>= 5.75 |

## Providers

| Name                                             | Version  |
|--------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider_aws) | \>= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                               | Type        |
|------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                      | resource    |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                          | resource    |
| [aws_scheduler_schedule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule)      | resource    |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name                                                                                          | Description                                                              | Type     | Default | Required |
|-----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|----------|---------|:--------:|
| <a name="input_message_body"></a> [message\_body](#input\_message\_body)                      | The content of the message body                                          | `string` | null    |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                | The base name for resources, used to create unique resource identifiers. | `string` | null    |   yes    |
| <a name="input_queue_url"></a> [queue\_url](#input\_queue\_url)                               | The URL of the SQS queue                                                 | `string` | null    |   yes    |
| <a name="input_sqs_arn"></a> [sqs\_arn](#input\_sqs\_arn)                                     | The ARN of the target SQS queue where messages will be sent.             | `string` | null    |   yes    |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | A cron schedule expression defining when the task runs.                  | `string` | null    |    no    |
| <a name="input_schedule_expression_timezone"></a> [schedule\_expression\_timezone](#input\_schedule\_expression\_timezone) | (Optional) Timezone in which the scheduling expression is evaluated. Defaults to UTC | `string` | `"UTC"` |    no    |

## Outputs

| Name                                                                                                                                      | Description                                           |
|-------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|
| <a name="output_iam_policy_access_scheduler_arn"></a> [iam\_policy\_access\_scheduler\_arn](#output\_iam\_policy\_access\_scheduler\_arn) | The ARN of the IAM policy for accessing the scheduler |
| <a name="output_scheduler_arn"></a> [scheduler\_arn](#output\_scheduler\_arn)                                                             | The ARN of the scheduler schedule                     |
| <a name="output_scheduler_role_arn"></a> [scheduler\_role\_arn](#output\_scheduler\_role\_arn)                                            | The ARN of the IAM role associated with the scheduler |

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
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_scheduler_schedule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_message_body"></a> [message\_body](#input\_message\_body) | The content of the message body | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The base name for resources, used to create unique resource identifiers. | `string` | n/a | yes |
| <a name="input_queue_url"></a> [queue\_url](#input\_queue\_url) | The URL of the SQS queue | `string` | n/a | yes |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | A cron schedule expression defining when the task runs | `string` | n/a | yes |
| <a name="input_schedule_expression_timezone"></a> [schedule\_expression\_timezone](#input\_schedule\_expression\_timezone) | (Optional) Timezone in which the scheduling expression is evaluated. Defaults to UTC | `string` | `null` | no |
| <a name="input_sqs_arn"></a> [sqs\_arn](#input\_sqs\_arn) | The ARN of the target SQS queue where messages will be sent. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_policy_access_scheduler_arn"></a> [iam\_policy\_access\_scheduler\_arn](#output\_iam\_policy\_access\_scheduler\_arn) | The ARN of the IAM policy for accessing the scheduler |
| <a name="output_scheduler_arn"></a> [scheduler\_arn](#output\_scheduler\_arn) | The ARN of the scheduler schedule |
| <a name="output_scheduler_role_arn"></a> [scheduler\_role\_arn](#output\_scheduler\_role\_arn) | The ARN of the IAM role associated with the scheduler |
<!-- END_TF_DOCS -->
