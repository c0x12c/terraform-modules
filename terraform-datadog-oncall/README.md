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
| [datadog_on_call_escalation_policy.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/on_call_escalation_policy) | resource |
| [datadog_on_call_schedule.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/on_call_schedule) | resource |
| [datadog_on_call_team_routing_rules.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/on_call_team_routing_rules) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_escalation_policy"></a> [escalation\_policy](#input\_escalation\_policy) | Configuration for the on-call escalation policy. | <pre>object({<br/>    name                       = string<br/>    resolve_page_on_policy_end = bool<br/>    retries                    = number<br/>  })</pre> | n/a | yes |
| <a name="input_escalation_policy_escalate_after_seconds"></a> [escalation\_policy\_escalate\_after\_seconds](#input\_escalation\_policy\_escalate\_after\_seconds) | The number of seconds after which to escalate the on-call notification. | `number` | `60` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Configuration for the on-call schedule, including name, time zone, and layer details. | <pre>object({<br/>    name      = string<br/>    time_zone = string<br/>    layer = object({<br/>      name           = string<br/>      effective_date = string<br/>      rotation_start = string<br/>      interval_days  = number<br/>      users          = list(string)<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_team_id"></a> [team\_id](#input\_team\_id) | The ID of the Datadog team to associate with the on-call resources. | `string` | n/a | yes |
| <a name="input_urgency"></a> [urgency](#input\_urgency) | The urgency level for the routing rule. | `string` | `"high"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_escalation_policy_id"></a> [escalation\_policy\_id](#output\_escalation\_policy\_id) | The ID of the Datadog on-call escalation policy |
| <a name="output_routing_rule_team_id"></a> [routing\_rule\_team\_id](#output\_routing\_rule\_team\_id) | The ID of the Datadog on-call team routing rules |
| <a name="output_schedule_id"></a> [schedule\_id](#output\_schedule\_id) | The ID of the created Datadog on-call schedule |

<!-- END_TF_DOCS -->
