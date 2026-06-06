# AWS SNS Terraform module

Terraform module which creates SNS resources on AWS.

## Usage

### Create SNS

```hcl
module "ses" {
  source = "github.com/spartan-stratos/terraform-modules//aws/sns?ref=v0.1.44"
  
  name = "sns-topic"
  subscriptions = [
    {
      name     = "sqs-email-received-local"
      protocol = "sqs"
      endpoint = "queue-arn"
    }
  ]
}
```

## Examples

- [Example](./examples/complete/)

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

| Name                                                                                                                                  | Type     |
|---------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                           | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name                                                                      | Description                                                                                                                                                                                                                                                                                                                                                 | Type                                                                                                               | Default | Required |
|---------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name)                            | The name of the SNS topic to be created.                                                                                                                                                                                                                                                                                                                    | `string`                                                                                                           | n/a     |   yes    |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | A list of subscription objects specifying details for each subscription.<br/>Each subscription object must contain:<br/>  - `name`: A unique name for the subscription.<br/>  - `protocol`: The protocol to use for the subscription (e.g., "email", "https").<br/>  - `endpoint`: The endpoint to send notifications to (e.g., an email address or a URL). | <pre>list(object({<br/>    name     = string<br/>    protocol = string,<br/>    endpoint = string,<br/>  }))</pre> | n/a     |   yes    |

## Outputs

| Name                                          | Description |
|-----------------------------------------------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a         |

<!-- END_TF_DOCS -->
