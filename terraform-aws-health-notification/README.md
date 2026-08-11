# terraform-aws-health-notification

Delivers AWS Health Dashboard events to Slack, email, or any SNS subscriber.

```
AWS Health ──► EventBridge rule ──► SNS topic ──┬─► AWS Chatbot (Slack)
                                                ├─► email
                                                ├─► https webhook
                                                └─► lambda / sqs
```

Delivery inputs are maps — add or drop channels without touching the rule.

## Prerequisites

Chatbot needs manual setup first. Skipping a step gives a config that applies
cleanly but never delivers.

1. Slack: add the *Amazon Q Developer* app. Needs workspace admin approval.
2. AWS console → Amazon Q Developer in chat applications → *Configure new client*
   → Slack → *Allow*. Once per account. Gives you `workspace_id`.
3. In the channel: `/invite @Amazon Q`. **Easiest step to miss — without it
   Terraform still reports success and nothing arrives.**
4. Channel ID, not name: right-click channel → *Copy Link* → trailing segment
   (`C0XXXXXXX`). Private channels work once the bot is invited.

Read `workspace_id` back from the API rather than hunting for it in the console:

```bash
aws chatbot describe-slack-workspaces
```

An empty `SlackWorkspaces` list means step 2 has not been done in this account.
Terraform still plans fine in that state; the apply fails at the Chatbot API.

Email, https, lambda and sqs need no setup. No paid AWS Support plan required.

## Usage

```hcl
module "health_notification" {
  source  = "terraform.c0x12c.com/c0x12c/health-notification/aws"
  version = "~> 0.2"

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

All events are forwarded by default. To narrow:

```hcl
event_type_categories = ["issue", "scheduledChange"]
services              = ["EC2", "RDS", "EKS"]
```

## Verifying

There is no way to synthesize a Health event — EventBridge rejects `put-events`
with an `aws.` prefixed source, so the path can only be exercised by a real one.
What you can check immediately after apply:

```bash
# The channel config exists and points at the right channel.
aws chatbot describe-slack-channel-configurations

# The rule is enabled and its pattern is what you expect.
aws events describe-rule --name <name>-health-notification
```

Then confirm the bot is actually in the channel — `/invite @Amazon Q` is the
step that fails silently. Once events start arriving, `MatchedEvents` on the
`AWS/Events` namespace (dimension `RuleName`) tells you the rule fired, which
separates "no events yet" from "events matched but Slack never rendered them".

## Notes

Region coverage — a rule only sees its own Region, and Regions differ:

- **us-west-2** — account-specific events from every standard-partition Region.
  Public events excluded.
- **us-east-1** — the only Region receiving global events (e.g. IAM). Deploy a
  second instance with an aliased provider to catch them, but give that instance
  `slack_channels = {}` and feed its topic to the first instance via
  `additional_sns_topic_arns`. A Slack channel accepts only **one** Chatbot
  configuration per AWS account, so two instances both naming the same channel
  fail the second apply with `has already been configured for AWS account`.
- Both back up other Regions, so both see duplicates. Set
  `exclude_backup_events = true`, or de-duplicate on `detail.communicationId`.

Silent-failure paths — all three apply cleanly and deliver nothing:

- `create_sns_topic = false` attaches no topic policy by default, so nothing
  grants `events.amazonaws.com` permission to publish. Set
  `manage_existing_topic_policy = true` to let the module own that policy, or
  add the `sns:Publish` grant yourself with an `aws:SourceArn` condition on the
  rule ARN.
- A customer-managed `sns_kms_master_key_id` needs its **key policy** to allow
  `events.amazonaws.com` to call `kms:GenerateDataKey*` and `kms:Decrypt`. The
  key is external, so the module cannot add it. `alias/aws/sns` needs nothing.
- Missing `/invite @Amazon Q` in the channel, as above.

All three surface only as EventBridge `FailedInvocations`, or as no metric at
all — worth an alarm on that metric once the rule is live.

Other:

- Public events can take up to an hour to start flowing after apply.
- Organizational view (member accounts) is out of scope — needs event forwarding
  into the management account's bus.
- `input_transformer` breaks Chatbot cards. Leave null when a Chatbot channel is
  attached.
- Email subscriptions stay `pending confirmation` until the recipient clicks
  through; Terraform reports them created regardless.
- Need a custom message body? Use
  [`terraform-aws-eventbridge-slack-notification`](../terraform-aws-eventbridge-slack-notification)
  instead — Lambda plus incoming webhook.

## Examples

See [`examples/complete`](examples/complete) for a runnable example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.61, < 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.61, < 7.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_chatbot_slack_channel_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/chatbot_slack_channel_configuration) | resource |
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
| <a name="input_additional_sns_topic_arns"></a> [additional\_sns\_topic\_arns](#input\_additional\_sns\_topic\_arns) | Extra SNS topic ARNs each Chatbot channel also subscribes to. A Slack channel can hold only one configuration per account, so a second Region's topic must be added here rather than by a second instance with its own slack\_channels. | `list(string)` | `[]` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Whether to create the shared IAM role assumed by AWS Chatbot. Ignored when no Chatbot channel is configured. | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Whether to create the SNS topic. Set false to publish into an existing topic. | `bool` | `true` | no |
| <a name="input_event_bus_name"></a> [event\_bus\_name](#input\_event\_bus\_name) | Event bus the rule attaches to. Defaults to the account's default bus, which is where AWS Health delivers. | `string` | `null` | no |
| <a name="input_event_pattern"></a> [event\_pattern](#input\_event\_pattern) | JSON-encoded event pattern that replaces the generated AWS Health pattern outright. Setting this ignores the filter inputs above. | `string` | `null` | no |
| <a name="input_event_type_categories"></a> [event\_type\_categories](#input\_event\_type\_categories) | Categories to forward: issue, accountNotification, scheduledChange, investigation. Empty forwards all. | `list(string)` | `[]` | no |
| <a name="input_event_type_codes"></a> [event\_type\_codes](#input\_event\_type\_codes) | Specific AWS Health event type codes to forward, e.g. AWS\_EC2\_INSTANCE\_STORE\_DRIVE\_PERFORMANCE\_DEGRADED. Empty forwards every code. | `list(string)` | `[]` | no |
| <a name="input_eventbridge_rule_description"></a> [eventbridge\_rule\_description](#input\_eventbridge\_rule\_description) | Description of the EventBridge rule. | `string` | `"Forward AWS Health Dashboard events to the notification topic"` | no |
| <a name="input_eventbridge_rule_name"></a> [eventbridge\_rule\_name](#input\_eventbridge\_rule\_name) | Name of the EventBridge rule. Defaults to {name}-health-notification. | `string` | `null` | no |
| <a name="input_exclude_backup_events"></a> [exclude\_backup\_events](#input\_exclude\_backup\_events) | Drop backup copies of other Regions' events. us-west-2 backs up all Regions and us-east-1 backs up us-west-2, so rules there see duplicates. | `bool` | `false` | no |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Managed policy ARNs attached to the created Chatbot role. | `list(string)` | <pre>[<br/>  "arn:aws:iam::aws:policy/AmazonQDeveloperAccess",<br/>  "arn:aws:iam::aws:policy/ReadOnlyAccess"<br/>]</pre> | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | ARN of an existing IAM role for AWS Chatbot, used by any channel that does not set its own iam\_role\_arn. | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role to create. Defaults to {name}-chatbot-role. | `string` | `null` | no |
| <a name="input_input_transformer"></a> [input\_transformer](#input\_input\_transformer) | Optional input transformer applied before publishing to SNS. Chatbot needs the raw event, so leave null when a Chatbot channel is attached. | <pre>object({<br/>    input_paths    = map(string)<br/>    input_template = string<br/>  })</pre> | `null` | no |
| <a name="input_manage_existing_topic_policy"></a> [manage\_existing\_topic\_policy](#input\_manage\_existing\_topic\_policy) | Attach the EventBridge publish policy to the existing topic named by sns\_topic\_arn. Replaces that topic's policy outright, so leave false when something else owns it and grant sns:Publish to events.amazonaws.com yourself. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix applied to created resources. | `string` | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | AWS service codes to forward, e.g. EC2 or RDS. Empty forwards every service. | `list(string)` | `[]` | no |
| <a name="input_slack_channels"></a> [slack\_channels](#input\_slack\_channels) | Chatbot Slack channel configs keyed by name. workspace\_id is the Slack team ID from the console authorization. | <pre>map(object({<br/>    workspace_id                = string<br/>    channel_id                  = string<br/>    configuration_name          = optional(string)<br/>    logging_level               = optional(string, "ERROR")<br/>    guardrail_policy_arns       = optional(list(string), [])<br/>    user_authorization_required = optional(bool, false)<br/>    iam_role_arn                = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_sns_kms_master_key_id"></a> [sns\_kms\_master\_key\_id](#input\_sns\_kms\_master\_key\_id) | KMS key ID or alias used to encrypt the created SNS topic. Null leaves the topic unencrypted. A customer-managed key also needs its key policy to allow events.amazonaws.com to call kms:GenerateDataKey* and kms:Decrypt, which this module cannot add; without it EventBridge deliveries fail after a successful apply. alias/aws/sns needs nothing. | `string` | `null` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of an existing SNS topic. Required when create\_sns\_topic is false. | `string` | `null` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of the SNS topic to create. Defaults to {name}-health-notification. | `string` | `null` | no |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | Plain SNS subscriptions keyed by name: email, https, lambda, sqs. Email stays pending until the recipient confirms. | <pre>map(object({<br/>    protocol             = string<br/>    endpoint             = string<br/>    raw_message_delivery = optional(bool, false)<br/>    filter_policy        = optional(string)<br/>    filter_policy_scope  = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all taggable resources. | `map(string)` | `{}` | no |

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
<!-- END_TF_DOCS -->
