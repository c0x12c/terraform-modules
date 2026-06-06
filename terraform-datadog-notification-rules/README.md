# Datadog Mono Monitor module

Terraform module that creates Datadog notification rules. These rules allow to filter alerts by tag and send to specified targets.

## Usage

### Create Datadog service monitors

```hcl
module "datadog_notification_rules" {
  source = "c0x12c/notification-rules/datadog"

  notification_rules = {
    prod_slack_rule = {
      name       = "Prod Slack Notification Rule"
      recipients = ["slack-prj-x-prod"]
      filter = {
        tags = ["env:prod"]
      }
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_monitor_notification_rule.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor_notification_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_notification_rules"></a> [notification\_rules](#input\_notification\_rules) | Datadog notification rules | <pre>map(object({<br/>    name       = string<br/>    recipients = list(string)<br/>    filter = optional(object({<br/>      tags = optional(list(string))<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_notification_rule_ids"></a> [notification\_rule\_ids](#output\_notification\_rule\_ids) | n/a |

<!-- END_TF_DOCS -->
