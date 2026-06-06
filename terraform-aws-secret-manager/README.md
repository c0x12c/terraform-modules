# AWS SecretManager Terraform module

This module provision AWS Secret Manager resources to manage secret value.

## Usage

### Create SecretManager

```hcl
module "secret_manager" {
  source = "github.com/spartan-stratos/terraform-modules//aws/secret-manager?ref=v0.2.0"

  secrets = {
    "API_KEY" = "VALUE"
    "TOKEN"   = "VALUE"
  }
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

## Outputs

| Name                                                                                                                                      | Description                                           |
|-------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|
| <a name="output_iam_policy_access_scheduler_arn"></a> [iam\_policy\_access\_scheduler\_arn](#output\_iam\_policy\_access\_scheduler\_arn) | The ARN of the IAM policy for accessing the scheduler |
| <a name="output_scheduler_arn"></a> [scheduler\_arn](#output\_scheduler\_arn)                                                             | The ARN of the scheduler schedule                     |
| <a name="output_scheduler_role_arn"></a> [scheduler\_role\_arn](#output\_scheduler\_role\_arn)                                            | The ARN of the IAM role associated with the scheduler |

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

| Name                                                                                                                                                | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                 | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name                                                                        | Description                                                                           | Type          | Default | Required |
|-----------------------------------------------------------------------------|---------------------------------------------------------------------------------------|---------------|---------|:--------:|
| <a name="input_secret_prefix"></a> [secret\_prefix](#input\_secret\_prefix) | The prefix of your secret name in format '{secret\_prefix}-{secret\_key}'.            | `string`      | `null`  |    no    |
| <a name="input_secrets"></a> [secrets](#input\_secrets)                     | A map of secrets to be stored in AWS Secrets Manager and passed into the application. | `map(string)` | n/a     |   yes    |

## Outputs

| Name                                                                    | Description |
|-------------------------------------------------------------------------|-------------|
| <a name="output_secrets_map"></a> [secrets\_map](#output\_secrets\_map) | n/a         |

<!-- END_TF_DOCS -->