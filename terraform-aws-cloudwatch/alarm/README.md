# Amazon CloudWatch Alarm Terraform module

Terraform module which creates Amazon CloudWatch Alarm resources.

## Usage

```hcl
module "cloudwatch-alarm" {
  source      = "github.com/spartan-stratos/terraform-modules//aws/cloudwatch/alarm?ref=v0.1.59"
  email       = "example-email"
  environment = "dev"
  alarms = {
    CPUUtilization = {
      name                = "example-alarm"
      description         = "example"
      comparison_operator = "example-comparison"
      evaluation_periods  = "1"
      metric_name         = "exammple-metric"
      namespace           = "example-namespace"
      period              = "example-period"
      statistic           = "Average"
      threshold           = "20"
    }
  }
}
```

## Examples

- [Example complete](./examples/complete/)

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

| Name                                                                                                                                    | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                             | resource |
| [aws_sns_topic_subscription.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name                                                                                            | Description                                                                                                                               | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Default | Required |
|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_alarms"></a> [alarms](#input\_alarms)                                            | A map of alarms to create                                                                                                                 | <pre>map(object({<br/>    name                = string<br/>    description         = string<br/>    comparison_operator = string<br/>    evaluation_periods  = string<br/>    metric_name         = string<br/>    namespace           = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = number<br/>    queue_name          = optional(string)<br/>    alb_name            = optional(string)<br/>    target_group_name   = optional(string)<br/>    instance_id         = optional(string)<br/>    auto_scaling_group  = optional(string)<br/>    currency            = optional(string)<br/>    linked_account      = optional(string)<br/>    identifier          = optional(string)<br/>  }))</pre> | n/a     |   yes    |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic)          | Creates a SNS Topic if `true`.                                                                                                            | `bool`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `true`  |    no    |
| <a name="input_datapoints_to_alarm"></a> [datapoints\_to\_alarm](#input\_datapoints\_to\_alarm) | The number of datapoints that must be breaching to trigger the alarm.                                                                     | `number`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `null`  |    no    |
| <a name="input_email"></a> [email](#input\_email)                                               | n/a                                                                                                                                       | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | n/a     |   yes    |
| <a name="input_environment"></a> [environment](#input\_environment)                             | AWS environment you are deploying to. Will be appended to SNS topic and alarm name. (e.g. dev, prod)                                      | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | n/a     |   yes    |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name)                              | The queue name of the SQS queue.                                                                                                          | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `null`  |    no    |
| <a name="input_sns_topic_arns"></a> [sns\_topic\_arns](#input\_sns\_topic\_arns)                | List of SNS topic ARNs to be used. If `create_sns_topic` is `true`, it merges the created SNS Topic by this module with this list of ARNs | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `[]`    |    no    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->