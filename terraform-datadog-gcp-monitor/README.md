# Datadog GCP Monitor module

Terraform module that creates Datadog monitors, supporting the following:

- GCP PostgreSQL monitoring

## Usage

### Create Datadog service monitors

```hcl
module "gcp_monitor" {
  source  = "c0x12c/gcp-monitor/datadog"
  version = "~> 1.0.0"

  notification_slack_channel_prefix = "project-x-alerts-"
  tag_slack_channel                 = true
  environment                       = "dev"

  override_default_monitors = {
    postgres_uptime_monitor = {
      priority_level           = 1
      title_tags               = "[Uptime] [PostgreSQL]"
      title                    = "GCP - PostgreSQL - Database is not healthy."
      override_default_message = "@ops-gennie-alerts @oncall-team" # default message mention slack channel

      query_template = "min($${timeframe}):sum:gcp.cloudsql.database.uptime{project_id:project-x} by {database_id} < $${threshold_critical}"
      query_args = {
        timeframe = "last_1m"
      }

      threshold_critical          = 55
      threshold_critical_recovery = 59
      renotify_interval           = 10
    }
  }
  postgres_monitor_enabled = true
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.46.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgres_monitor"></a> [postgres\_monitor](#module\_postgres\_monitor) | c0x12c/monitors/datadog | ~> 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_client_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where the resources will be created. | `string` | n/a | yes |
| <a name="input_notification_slack_channel_prefix"></a> [notification\_slack\_channel\_prefix](#input\_notification\_slack\_channel\_prefix) | The prefix for Slack channels that will receive notifcations and alerts | `string` | n/a | yes |
| <a name="input_override_default_monitors"></a> [override\_default\_monitors](#input\_override\_default\_monitors) | A map of overridden monitors. The key is the monitor name and the value is a map of monitor attributes. The following attributes are required:<br/>    - enabled: Whether the monitor is enabled.<br/>    - priority\_level: The priority level of the monitor.<br/>    - title\_tags: The tags to include in the title of the monitor.<br/>    - title: The title of the monitor.<br/>    - type: The type of the monitor.<br/>    - query\_template: The template for the monitor query.<br/>    - query\_args: The arguments for the monitor query.<br/>    - threshold\_critical: The critical threshold for the monitor.<br/>    - threshold\_critical\_recovery: The critical recovery threshold for the monitor.<br/>    - threshold\_ok: The recovery threshold for the monitor. Only supported in monitor type `service check`.<br/>    - renotify\_interval: The renotify interval for the monitor.<br/><br/>    The following attributes are optional:<br/>    - override\_default\_message: An optional message to override the default slack mention.<br/>    - renotify\_occurrences: The renotify occurrences for the monitor.<br/>    - require\_full\_window: Whether the monitor requires a full window.<br/>    - enabled\_include\_tags: Whether to include tags in the monitor.<br/>    - additional\_tags: Additional tags to include in the monitor.<br/>    - notification\_preset\_name: The notification preset name for the monitor. | <pre>map(object({<br/>    enabled                     = optional(bool)<br/>    priority_level              = optional(number)<br/>    title_tags                  = optional(string)<br/>    title                       = optional(string)<br/>    override_default_message    = optional(string)<br/>    type                        = optional(string)<br/>    query_template              = optional(string)<br/>    query_args                  = optional(map(string))<br/>    threshold_critical          = optional(number)<br/>    threshold_critical_recovery = optional(number)<br/>    threshold_ok                = optional(number)<br/>    renotify_interval           = optional(number)<br/>    renotify_occurrences        = optional(number)<br/>    require_full_window         = optional(bool)<br/>    enabled_include_tags        = optional(bool)<br/>    additional_tags             = optional(list(string))<br/>    notification_preset_name    = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_postgres_monitor_enabled"></a> [postgres\_monitor\_enabled](#input\_postgres\_monitor\_enabled) | Whether to enable monitoring of postgres | `bool` | `true` | no |
| <a name="input_tag_slack_channel"></a> [tag\_slack\_channel](#input\_tag\_slack\_channel) | Whether to tag the Slack channel in the message | `bool` | `true` | no |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
