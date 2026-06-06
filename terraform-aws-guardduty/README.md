# AWS GuardDuty module

Terraform module which creates GuardDuty resources on AWS.

This module will create the following components:

- GuardDuty Detector: Enables GuardDuty with optional configurations for EKS audit logs and S3 scanning.
- SNS Topic: Sends notifications of GuardDuty findings.
- SNS Topic Subscription: Configures email recipients for GuardDuty notifications.
- CloudWatch Event Rule: Captures GuardDuty finding events.
- CloudWatch Event Target: Routes findings to the SNS topic and transforms event data into a human-readable format.

## Usage

### Create GuardDuty

```hcl
module "guardduty" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/guardduty?ref=v0.1.23"

  name                                    = "example"
  enabled_guardduty                       = true
  enabled_guardduty_eks_audit             = true
  enabled_guardduty_s3_scanning           = true
  enabled_email_notification              = true
  notifications_received_email_list       = true
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                    | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)     | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)           | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                             | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)   | resource |

## Inputs

| Name                                                                                                                                                            | Description                                            | Type           | Default | Required |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_enabled_email_notification"></a> [enabled\_email\_notification](#input\_enabled\_email\_notification)                                            | Whether enabling GuardDuty notifications to emails     | `bool`         | `false` |    no    |
| <a name="input_enabled_guardduty"></a> [enabled\_guardduty](#input\_enabled\_guardduty)                                                                         | Whether enabling GuardDuty for IPS/IDS                 | `bool`         | `false` |    no    |
| <a name="input_enabled_guardduty_ebs_malware_detection"></a> [enabled\_guardduty\_ebs\_malware\_detection](#input\_enabled\_guardduty\_ebs\_malware\_detection) | Whether enabling GuardDuty for scanning EBS malware    | `bool`         | `false` |    no    |
| <a name="input_enabled_guardduty_eks_audit"></a> [enabled\_guardduty\_eks\_audit](#input\_enabled\_guardduty\_eks\_audit)                                       | Whether enabling GuardDuty for scanning EKS Audit logs | `bool`         | `false` |    no    |
| <a name="input_enabled_guardduty_s3_scanning"></a> [enabled\_guardduty\_s3\_scanning](#input\_enabled\_guardduty\_s3\_scanning)                                 | Whether enabling GuardDuty for scanning S3 logs        | `bool`         | `false` |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                                  | The name of resources                                  | `string`       | n/a     |   yes    |
| <a name="input_notifications_received_email_list"></a> [notifications\_received\_email\_list](#input\_notifications\_received\_email\_list)                     | List of emails to receive GuardDuty findings           | `list(string)` | `[]`    |    no    |

## Outputs

| Name                                                                 | Description                                          |
|----------------------------------------------------------------------|------------------------------------------------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account ID of the GuardDuty detector         |
| <a name="output_arn"></a> [arn](#output\_arn)                        | Amazon Resource Name (ARN) of the GuardDuty detector |

<!-- END_TF_DOCS -->
