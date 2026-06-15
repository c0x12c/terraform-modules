# Datadog Service Monitor module

Terraform module which creates Datadog monitors for services, supporting:

- Python

with monitors:

- Pod statuses (Failed, CrashLoopBackOff, PullImageBackOff)
- Pod resource utilization (CPU, memory)
- Service P95 latency, request hit, error hit.

## Usage

### Create Datadog service monitors

```hcl
module "service_monitor" {
  source  = "terraform.c0x12c.com/c0x12c/service-monitor/datadog"
  version = "0.7.0"

  cluster_name                      = "proj-service-dev"
  service_name                      = "service-platform"
  environment                       = "dev"
  tag_slack_channel                 = false
  notification_slack_channel_prefix = "proj-service-x-"

  pod_monitor_enabled     = true
  cpu_monitor_enabled     = true
  memory_monitor_enabled  = true
  service_monitor_enabled = true
}
```

### Override default monitor thresholds

Override only the fields you want to change; everything else (title,
`query_template`, etc.) keeps the module defaults. Partial overrides are
supported:

```hcl
module "service_monitor" {
  source = "terraform.c0x12c.com/c0x12c/service-monitor/datadog"

  cluster_name                      = "proj-service-dev"
  service_name                      = "service-platform"
  environment                       = "dev"
  notification_slack_channel_prefix = "proj-service-x-"

  service_monitor_enabled = true

  override_default_monitors = {
    p95 = {
      threshold_critical          = 2 # alert when P95 latency > 2s
      threshold_critical_recovery = 1.8
    }
  }
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
| <a name="module_cpu"></a> [cpu](#module\_cpu) | c0x12c/monitors/datadog | ~> 1.0.0 |
| <a name="module_memory"></a> [memory](#module\_memory) | c0x12c/monitors/datadog | ~> 1.0.0 |
| <a name="module_pod"></a> [pod](#module\_pod) | c0x12c/monitors/datadog | ~> 1.0.0 |
| <a name="module_service"></a> [service](#module\_service) | c0x12c/monitors/datadog | ~> 1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The Kubernetes cluster name | `string` | n/a | yes |
| <a name="input_cpu_monitor_enabled"></a> [cpu\_monitor\_enabled](#input\_cpu\_monitor\_enabled) | Whether cpu monitors should be created. Set to 'true' to create the monitors, 'false' to disable. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where the resources will be created. | `string` | n/a | yes |
| <a name="input_error_hit_metric"></a> [error\_hit\_metric](#input\_error\_hit\_metric) | The metric name used for counting request errors. | `string` | `"trace.http.request.errors"` | no |
| <a name="input_memory_monitor_enabled"></a> [memory\_monitor\_enabled](#input\_memory\_monitor\_enabled) | Whether memory monitors should be created. Set to 'true' to create the monitors, 'false' to disable. | `bool` | `false` | no |
| <a name="input_notification_slack_channel_prefix"></a> [notification\_slack\_channel\_prefix](#input\_notification\_slack\_channel\_prefix) | The prefix for Slack channels that will receive notifcations and alerts | `string` | n/a | yes |
| <a name="input_override_default_monitors"></a> [override\_default\_monitors](#input\_override\_default\_monitors) | A map of overridden monitors. The key is the monitor name and the value is a map of monitor attributes. The following attributes are required:<br/>    - enabled: Whether the monitor is enabled.<br/>    - priority\_level: The priority level of the monitor.<br/>    - title\_tags: The tags to include in the title of the monitor.<br/>    - title: The title of the monitor.<br/>    - type: The type of the monitor.<br/>    - query\_template: The template for the monitor query.<br/>    - query\_args: The arguments for the monitor query.<br/>    - threshold\_critical: The critical threshold for the monitor.<br/>    - threshold\_critical\_recovery: The critical recovery threshold for the monitor.<br/>    - threshold\_ok: The recovery threshold for the monitor. Only supported in monitor type `service check`.<br/>    - renotify\_interval: The renotify interval for the monitor.<br/><br/>    The following attributes are optional:<br/>    - override\_default\_message: An optional message to override the default slack mention.<br/>    - renotify\_occurrences: The renotify occurrences for the monitor.<br/>    - require\_full\_window: Whether the monitor requires a full window.<br/>    - enabled\_include\_tags: Whether to include tags in the monitor.<br/>    - additional\_tags: Additional tags to include in the monitor.<br/>    - notification\_preset\_name: The notification preset name for the monitor. | <pre>map(object({<br/>    enabled                     = optional(bool)<br/>    priority_level              = optional(number)<br/>    title_tags                  = optional(string)<br/>    title                       = optional(string)<br/>    override_default_message    = optional(string)<br/>    type                        = optional(string)<br/>    query_template              = optional(string)<br/>    query_args                  = optional(map(string))<br/>    threshold_critical          = optional(number)<br/>    threshold_critical_recovery = optional(number)<br/>    threshold_ok                = optional(number)<br/>    renotify_interval           = optional(number)<br/>    renotify_occurrences        = optional(number)<br/>    require_full_window         = optional(bool)<br/>    enabled_include_tags        = optional(bool)<br/>    additional_tags             = optional(list(string))<br/>    notification_preset_name    = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_overwrite_container_name"></a> [overwrite\_container\_name](#input\_overwrite\_container\_name) | Specify the service's container name if it is different from variable `service_name`. | `string` | `null` | no |
| <a name="input_p95_metric"></a> [p95\_metric](#input\_p95\_metric) | The metric name used for P95 request latency calculations. | `string` | `"trace.http.request"` | no |
| <a name="input_pod_monitor_enabled"></a> [pod\_monitor\_enabled](#input\_pod\_monitor\_enabled) | Whether pod monitors (e.g., pod restarts.) should be created. Set to 'true' to create the monitors, 'false' to disable. | `bool` | `false` | no |
| <a name="input_request_hit_metric"></a> [request\_hit\_metric](#input\_request\_hit\_metric) | The metric name used for counting total requests (hits). | `string` | `"trace.http.request.hits"` | no |
| <a name="input_restart_on_missing_data"></a> [restart\_on\_missing\_data](#input\_restart\_on\_missing\_data) | The value to use for on\_missing\_data when creating the restart monitor. | `string` | `"resolve"` | no |
| <a name="input_service_monitor_enabled"></a> [service\_monitor\_enabled](#input\_service\_monitor\_enabled) | Whether service monitors (e.g., p95 latency, request and error hit.) should be created. Set to 'true' to create the monitors, 'false' to disable. | `bool` | `false` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Specify the service name for monitoring. Navigate to Datadog dashboard to have accurate determination. | `string` | n/a | yes |
| <a name="input_tag_slack_channel"></a> [tag\_slack\_channel](#input\_tag\_slack\_channel) | Whether to tag the Slack channel in the message | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->