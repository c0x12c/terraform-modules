# AWS EventBridge Slack Notification Module

This module creates a reusable notification system that sends AWS EventBridge events to Slack using Lambda.

## Features

- Lambda function for processing EventBridge events and sending to Slack
- IAM role and policies for Lambda execution
- Support for multiple EventBridge rules
- Customizable Lambda handler and runtime
- Support for additional IAM policies (service-specific permissions)

## Usage

```hcl
module "notification" {
  source  = "terraform.c0x12c.com/c0x12c/eventbridge-slack-notification/aws"
  version = "1.2.0"

  name              = "my-service-notifier"
  environment       = "production"
  slack_webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

  lambda_source_file = "${path.module}/files/index.mjs"
  lambda_handler     = "index.handler"
  lambda_runtime     = "nodejs22.x"

  lambda_environment_variables = {
    SERVICE_NAME = "my-service"
  }

  additional_iam_policy_arns = [
    aws_iam_policy.service_specific_policy.arn
  ]

  event_rules = [
    {
      name        = "my-service-events"
      description = "Service events"
      event_pattern = {
        source      = ["aws.ecs"]
        detail-type = ["ECS Task State Change"]
      }
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |
| archive | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name prefix for all resources | `string` | n/a | yes |
| environment | The environment name | `string` | n/a | yes |
| slack_webhook_url | Slack webhook URL for sending notifications | `string` | n/a | yes |
| lambda_source_file | Path to the Lambda function source file | `string` | n/a | yes |
| lambda_handler | Lambda function handler | `string` | `"index.handler"` | no |
| lambda_runtime | Lambda function runtime | `string` | `"nodejs22.x"` | no |
| lambda_environment_variables | Additional environment variables for the Lambda function | `map(string)` | `{}` | no |
| additional_iam_policy_arns | Additional IAM policy ARNs to attach to the Lambda execution role | `list(string)` | `[]` | no |
| event_rules | List of EventBridge rule configurations | `list(object)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| lambda_function_arn | ARN of the Lambda function |
| lambda_function_name | Name of the Lambda function |
| iam_role_arn | ARN of the Lambda execution IAM role |
| iam_role_name | Name of the Lambda execution IAM role |
| event_rule_arns | ARNs of the CloudWatch Event Rules |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.lambda_logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_logs_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.notifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_iam_policy_arns"></a> [additional\_iam\_policy\_arns](#input\_additional\_iam\_policy\_arns) | Additional IAM policy ARNs to attach to the Lambda execution role | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_event_rules"></a> [event\_rules](#input\_event\_rules) | List of EventBridge rule configurations | <pre>list(object({<br/>    name          = string<br/>    description   = string<br/>    event_pattern = any<br/>  }))</pre> | n/a | yes |
| <a name="input_lambda_environment_variables"></a> [lambda\_environment\_variables](#input\_lambda\_environment\_variables) | Additional environment variables for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_lambda_handler"></a> [lambda\_handler](#input\_lambda\_handler) | Lambda function handler | `string` | `"index.handler"` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Lambda function runtime | `string` | `"nodejs22.x"` | no |
| <a name="input_lambda_source_file"></a> [lambda\_source\_file](#input\_lambda\_source\_file) | Path to the Lambda function source file | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name prefix for all resources | `string` | n/a | yes |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | Slack webhook URL for sending notifications | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_rule_arns"></a> [event\_rule\_arns](#output\_event\_rule\_arns) | ARNs of the CloudWatch Event Rules |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the Lambda execution IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the Lambda execution IAM role |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | ARN of the Lambda function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | Name of the Lambda function |
<!-- END_TF_DOCS -->