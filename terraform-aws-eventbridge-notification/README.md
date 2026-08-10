# terraform-aws-eventbridge-notification

Routes AWS EventBridge events to Slack, Teams, email, or any SNS subscriber through one topic.

The rule defaults to the AWS Health Dashboard event feed, so account and service
health notices reach the team without a Lambda in the path.

```
EventBridge rule ──► SNS topic ──┬─► AWS Chatbot (Slack)
                                 ├─► AWS Chatbot (Microsoft Teams)
                                 ├─► email
                                 ├─► https webhook
                                 └─► lambda / sqs
```

Every delivery input is a map, so channels can be added or dropped without
touching the rule. Use
[`terraform-aws-eventbridge-slack-notification`](../terraform-aws-eventbridge-slack-notification)
instead when the message body needs custom formatting — that module renders
events with a Lambda and an incoming webhook.

## Prerequisites

AWS Chatbot must already be authorized against the Slack workspace or Teams
tenant. Do this once per account in the console (Chatbot → Configure new client);
the OAuth handshake cannot be done from Terraform. The IDs it returns are the
`workspace_id` / `team_id` inputs.

## Usage

```hcl
module "health_notification" {
  source  = "terraform.c0x12c.com/c0x12c/eventbridge-notification/aws"
  version = "~> 0.1"

  name = "example"

  slack_channels = {
    alerts = {
      workspace_id = "T0XXXXXXX"
      channel_id   = "C0XXXXXXX"
    }
  }

  subscriptions = {
    oncall_email = {
      protocol = "email"
      endpoint = "oncall@example.com"
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

Point the rule at something other than AWS Health with `event_pattern`:

```hcl
event_pattern = jsonencode({
  source        = ["aws.cloudwatch"]
  "detail-type" = ["CloudWatch Alarm State Change"]
})
```

## Notes

- **Regional scope.** An EventBridge rule only sees events delivered to its own
  region. AWS Health publishes account-level and global-service events to
  **us-east-1** regardless of where the affected resource lives, so deploy a
  second instance with a provider aliased to `us-east-1` to catch those.
- **Input transformer.** `input_transformer` reshapes the payload before it
  reaches SNS. Chatbot needs the raw event to render a card, so leave it null
  whenever a Chatbot channel is attached.
- **Email subscriptions** stay `pending confirmation` until the recipient clicks
  the confirmation link; Terraform reports them as created either way.

## Examples

See [`examples/complete`](examples/complete) for a runnable example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.62, < 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.62, < 7.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_chatbot_slack_channel_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/chatbot_slack_channel_configuration) | resource |
| [aws_chatbot_teams_channel_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/chatbot_teams_channel_configuration) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.chatbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.chatbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.chatbot_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Whether to create the shared IAM role assumed by AWS Chatbot. Ignored when no Chatbot channel is configured. | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Whether to create the SNS topic. Set false to publish into an existing topic. | `bool` | `true` | no |
| <a name="input_event_bus_name"></a> [event\_bus\_name](#input\_event\_bus\_name) | Event bus the rule attaches to. Defaults to the account's default bus. | `string` | `null` | no |
| <a name="input_event_pattern"></a> [event\_pattern](#input\_event\_pattern) | JSON-encoded event pattern for the EventBridge rule. Defaults to all AWS Health events. | `string` | `null` | no |
| <a name="input_eventbridge_rule_description"></a> [eventbridge\_rule\_description](#input\_eventbridge\_rule\_description) | Description of the EventBridge rule. | `string` | `"Forward matched events to the notification topic"` | no |
| <a name="input_eventbridge_rule_name"></a> [eventbridge\_rule\_name](#input\_eventbridge\_rule\_name) | Name of the EventBridge rule. Defaults to {name}-notification. | `string` | `null` | no |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Managed policy ARNs attached to the created Chatbot role. | `list(string)` | <pre>[<br/>  "arn:aws:iam::aws:policy/AmazonQDeveloperAccess",<br/>  "arn:aws:iam::aws:policy/ReadOnlyAccess"<br/>]</pre> | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | ARN of an existing IAM role for AWS Chatbot, used by any channel that does not set its own iam\_role\_arn. | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role to create. Defaults to {name}-chatbot-role. | `string` | `null` | no |
| <a name="input_input_transformer"></a> [input\_transformer](#input\_input\_transformer) | Optional input transformer applied before publishing to SNS. Chatbot needs the raw event, so leave null when a Chatbot channel is attached. | <pre>object({<br/>    input_paths    = map(string)<br/>    input_template = string<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix applied to created resources. | `string` | n/a | yes |
| <a name="input_slack_channels"></a> [slack\_channels](#input\_slack\_channels) | AWS Chatbot Slack channel configurations keyed by an arbitrary name.<br/>workspace\_id is the Slack team ID returned when Chatbot is authorized<br/>against the workspace, which must be done once in the console. | <pre>map(object({<br/>    workspace_id                = string<br/>    channel_id                  = string<br/>    configuration_name          = optional(string)<br/>    logging_level               = optional(string, "ERROR")<br/>    guardrail_policy_arns       = optional(list(string), [])<br/>    user_authorization_required = optional(bool, false)<br/>    iam_role_arn                = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_sns_kms_master_key_id"></a> [sns\_kms\_master\_key\_id](#input\_sns\_kms\_master\_key\_id) | KMS key ID or alias used to encrypt the created SNS topic. Null leaves the topic unencrypted. | `string` | `null` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of an existing SNS topic. Required when create\_sns\_topic is false. | `string` | `null` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of the SNS topic to create. Defaults to {name}-notification. | `string` | `null` | no |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | Plain SNS subscriptions keyed by an arbitrary name — email, https webhook,<br/>lambda, sqs, and so on. Non-confirming protocols such as email stay pending<br/>until the recipient accepts the subscription. | <pre>map(object({<br/>    protocol             = string<br/>    endpoint             = string<br/>    raw_message_delivery = optional(bool, false)<br/>    filter_policy        = optional(string)<br/>    filter_policy_scope  = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all taggable resources. | `map(string)` | `{}` | no |
| <a name="input_teams_channels"></a> [teams\_channels](#input\_teams\_channels) | AWS Chatbot Microsoft Teams channel configurations keyed by an arbitrary<br/>name. The Teams client must be authorized once in the console first. | <pre>map(object({<br/>    team_id                     = string<br/>    channel_id                  = string<br/>    tenant_id                   = string<br/>    team_name                   = optional(string)<br/>    channel_name                = optional(string)<br/>    configuration_name          = optional(string)<br/>    logging_level               = optional(string, "ERROR")<br/>    guardrail_policy_arns       = optional(list(string), [])<br/>    user_authorization_required = optional(bool, false)<br/>    iam_role_arn                = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventbridge_rule_arn"></a> [eventbridge\_rule\_arn](#output\_eventbridge\_rule\_arn) | ARN of the EventBridge rule. |
| <a name="output_eventbridge_rule_name"></a> [eventbridge\_rule\_name](#output\_eventbridge\_rule\_name) | Name of the EventBridge rule. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the shared IAM role assumed by AWS Chatbot. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the created IAM role, or null when none was created. |
| <a name="output_slack_channel_arns"></a> [slack\_channel\_arns](#output\_slack\_channel\_arns) | ARNs of the Chatbot Slack channel configurations, keyed as in var.slack\_channels. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the SNS topic events are published to. |
| <a name="output_sns_topic_name"></a> [sns\_topic\_name](#output\_sns\_topic\_name) | Name of the created SNS topic, or null when an existing topic is reused. |
| <a name="output_subscription_arns"></a> [subscription\_arns](#output\_subscription\_arns) | ARNs of the plain SNS subscriptions, keyed as in var.subscriptions. |
| <a name="output_teams_channel_arns"></a> [teams\_channel\_arns](#output\_teams\_channel\_arns) | ARNs of the Chatbot Teams channel configurations, keyed as in var.teams\_channels. |
<!-- END_TF_DOCS -->
