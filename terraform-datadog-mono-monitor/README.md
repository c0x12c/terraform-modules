# Datadog Mono Monitor module

Terraform module that creates standalone Datadog monitors, supporting the following:

- HTTP check
- Pod service statuses (Restarted)

## Usage

### Create Datadog service monitors

```hcl
module "mono_monitor" {
  source  = "c0x12c/mono-monitor/datadog"
  version = "~> 1.0.0"

  notification_slack_channel_prefix = "proj-service-x-"
  environment                       = "dev"
  tag_slack_channel                 = false
  cluster_name                      = "proj-service-dev"

  pod_monitor_enabled = true
  http_check_enabled  = true
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.46 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_http_check"></a> [http\_check](#module\_http\_check) | c0x12c/monitors/datadog | ~> 0.1.38 |
| <a name="module_pod"></a> [pod](#module\_pod) | c0x12c/monitors/datadog | ~> 0.1.38 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The Kubernetes cluster name | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where the resources will be created. | `string` | n/a | yes |
| <a name="input_http_check_enabled"></a> [http\_check\_enabled](#input\_http\_check\_enabled) | Whether http check monitors should be created. Set to 'true' to create the monitors, 'false' to disable. | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Whether to specific the namespace of service that is belong to | `string` | n/a | yes |
| <a name="input_notification_slack_channel_prefix"></a> [notification\_slack\_channel\_prefix](#input\_notification\_slack\_channel\_prefix) | The prefix for Slack channels that will receive notifcations and alerts | `string` | n/a | yes |
| <a name="input_override_default_monitors"></a> [override\_default\_monitors](#input\_override\_default\_monitors) | A map of overridden monitors. The key is the monitor name and the value is a map of monitor attributes. The following attributes are required:<br/>    - enabled: Whether the monitor is enabled.<br/>    - priority\_level: The priority level of the monitor.<br/>    - title\_tags: The tags to include in the title of the monitor.<br/>    - title: The title of the monitor.<br/>    - type: The type of the monitor.<br/>    - query\_template: The template for the monitor query.<br/>    - query\_args: The arguments for the monitor query.<br/>    - threshold\_critical: The critical threshold for the monitor.<br/>    - threshold\_critical\_recovery: The critical recovery threshold for the monitor.<br/>    - threshold\_ok: The recovery threshold for the monitor. Only supported in monitor type `service check`.<br/>    - renotify\_interval: The renotify interval for the monitor.<br/><br/>    The following attributes are optional:<br/>    - renotify\_occurrences: The renotify occurrences for the monitor.<br/>    - require\_full\_window: Whether the monitor requires a full window.<br/>    - enabled\_include\_tags: Whether to include tags in the monitor.<br/>    - additional\_tags: Additional tags to include in the monitor.<br/>    - notification\_preset\_name: The notification preset name for the monitor. | <pre>map(object({<br/>    enabled                     = optional(bool)<br/>    priority_level              = optional(number)<br/>    title_tags                  = optional(string)<br/>    title                       = optional(string)<br/>    type                        = optional(string)<br/>    query_template              = optional(string)<br/>    query_args                  = optional(map(string))<br/>    threshold_critical          = optional(number)<br/>    threshold_critical_recovery = optional(number)<br/>    threshold_ok                = optional(number)<br/>    renotify_interval           = optional(number)<br/>    renotify_occurrences        = optional(number)<br/>    require_full_window         = optional(bool)<br/>    enabled_include_tags        = optional(bool)<br/>    additional_tags             = optional(list(string))<br/>    notification_preset_name    = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_pod_monitor_enabled"></a> [pod\_monitor\_enabled](#input\_pod\_monitor\_enabled) | Whether pod monitors (e.g., pod statuses: crash\_loop\_back\_off, image\_pull\_back\_off, failed.) should be created. Set to 'true' to create the monitors, 'false' to disable. | `bool` | `false` | no |
| <a name="input_tag_slack_channel"></a> [tag\_slack\_channel](#input\_tag\_slack\_channel) | Whether to tag the Slack channel in the message | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
