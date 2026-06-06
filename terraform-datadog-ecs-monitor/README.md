# Terraform Datadog ECS Monitor

Terraform module for creating comprehensive Datadog monitors for AWS ECS services. This module provides pre-configured monitors for ECS service health, task performance, cluster capacity (EC2 launch type), and APM/trace metrics.

## Features

- **ECS Service Monitors**: CPU, memory utilization, running task count, pending tasks
- **APM Monitors**: P95/P99 latency, error rate, error count, throughput drop detection
- **Log Monitors**: Noise-reduced error detection using change detection, anomaly detection, and percentage-based thresholds

## Usage

### Basic Usage (Fargate)

```hcl
module "ecs_monitors" {
  source  = "c0x12c/ecs-monitor/datadog"
  version = "~> 1.0.0"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "my-service"

  notification_slack_channel_prefix = "alerts-"
  tag_slack_channel                 = true

  enabled_monitors = ["service", "apm"]

  apm_service_name = "my-service"
}
```

### EC2 Launch Type with Cluster Monitors

```hcl
module "ecs_monitors" {
  source  = "c0x12c/ecs-monitor/datadog"
  version = "~> 1.0.0"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-ec2-cluster"
  ecs_service_name = "my-service"
  launch_type      = "EC2"

  notification_slack_channel_prefix = "alerts-"

  enabled_monitors = ["service", "cluster", "apm"]
}
```

### Monitor All Services in a Cluster

```hcl
module "ecs_monitors" {
  source  = "c0x12c/ecs-monitor/datadog"
  version = "~> 1.0.0"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "*"  # Monitor all services

  notification_slack_channel_prefix = "alerts-"

  enabled_monitors = ["service"]
}
```

### With Log Monitors

```hcl
module "ecs_monitors" {
  source  = "c0x12c/ecs-monitor/datadog"
  version = "~> 1.0.0"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "my-service"

  notification_slack_channel_prefix = "alerts-"

  # Enable service, APM, and log monitors
  enabled_monitors = ["service", "apm", "logs"]

  apm_service_name = "my-service"

  # Log monitor thresholds (optional, showing defaults)
  log_error_count_threshold     = 50   # 50 errors in 15min
  log_critical_error_threshold  = 5    # 5 critical errors in 10min
  log_sustained_error_threshold = 100  # 100 errors sustained over 1 hour
}
```

### Custom Thresholds

```hcl
module "ecs_monitors" {
  source  = "c0x12c/ecs-monitor/datadog"
  version = "~> 1.0.0"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "my-service"

  notification_slack_channel_prefix = "alerts-"

  # Custom thresholds
  cpu_critical_threshold    = 85
  cpu_warning_threshold     = 75
  memory_critical_threshold = 85
  memory_warning_threshold  = 75
  p95_latency_threshold     = 0.5  # 500ms
  error_rate_threshold      = 0.5  # 0.5%
}
```

### Selective Channel Tagging by Priority

Control which severity levels trigger @channel tags in Slack notifications:

```hcl
module "ecs_monitors" {
  source  = "c0x12c/ecs-monitor/datadog"
  version = "~> 1.0.0"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "my-service"

  notification_slack_channel_prefix = "alerts-"
  tag_slack_channel                 = true
  escalate_min_priority          = 2  # Only tag @channel for P1 and P2, not P3

  enabled_monitors = ["service", "apm"]
}
```

This configuration will:
- Tag @channel for P1 (Critical) and P2 (High) alerts
- Skip @channel tagging for P3 (Medium) alerts like `apm_throughput_drop` and `apm_p95_latency`
- Still send notifications to the Slack channel for all alerts

### Override Specific Monitors

```hcl
module "ecs_monitors" {
  source  = "c0x12c/ecs-monitor/datadog"
  version = "~> 1.0.0"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "my-service"

  notification_slack_channel_prefix = "alerts-"

  override_default_monitors = {
    service_cpu_high = {
      threshold_critical = 90
      renotify_interval  = 15
    }
    apm_p95_latency = {
      enabled = false  # Disable this monitor
    }
  }
}
```

## Available Monitors

### Service Monitors

| Monitor | Description | Priority | Default Threshold |
|---------|-------------|----------|-------------------|
| `service_cpu_high` | High CPU utilization | P2 | 80% critical, 70% warning |
| `service_cpu_critical` | Critical CPU utilization | P1 | 95% critical |
| `service_memory_high` | High memory utilization | P2 | 80% critical, 70% warning |
| `service_memory_critical` | Critical memory - OOM risk | P1 | 95% critical |
| `service_running_tasks_low` | Running tasks below desired | P1 | < desired count |
| `service_task_count_zero` | No running tasks (service down) | P1 | = 0 |
| `service_pending_tasks_stuck` | Tasks stuck in pending state | P2 | > 0 for 10min |

### Cluster Monitors (EC2 Launch Type Only)

| Monitor | Description | Priority | Default Threshold |
|---------|-------------|----------|-------------------|
| `cluster_cpu_reservation_high` | High CPU reservation | P2 | 80% critical, 70% warning |
| `cluster_memory_reservation_high` | High memory reservation | P2 | 80% critical, 70% warning |
| `cluster_cpu_utilization_high` | High cluster CPU utilization | P2 | 85% critical |
| `cluster_memory_utilization_high` | High cluster memory utilization | P2 | 85% critical |

### APM Monitors

| Monitor | Description | Priority | Default Threshold |
|---------|-------------|----------|-------------------|
| `apm_p95_latency` | P95 latency is high | P3 | 1s critical |
| `apm_p99_latency` | P99 latency is high | P2 | 3s critical |
| `apm_error_rate` | Error rate is high | P2 | 1% critical |
| `apm_error_count` | Error count spike | P2 | 10 errors in 5min |
| `apm_throughput_drop` | Request throughput dropped | P3 | -50% change |

### Log Monitors

| Monitor | Description | Priority | Default Threshold |
|---------|-------------|----------|-------------------|
| `log_error_spike` | High volume of error logs | P2 | 50 errors in 15min |
| `log_critical_errors` | Critical errors (5xx, fatal, panic) | P1 | 5 in 10min |
| `log_sustained_errors` | Sustained errors over extended period | P2 | 100 in 1 hour |

## Priority Levels

| Priority | Severity | Renotify Interval |
|----------|----------|-------------------|
| P1 | Critical | 15 minutes |
| P2 | High | 30 minutes |
| P3 | Medium | 60 minutes |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.46.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apm_monitors"></a> [apm\_monitors](#module\_apm\_monitors) | c0x12c/monitors/datadog | ~> 1.0.0 |
| <a name="module_log_monitors"></a> [log\_monitors](#module\_log\_monitors) | c0x12c/monitors/datadog | ~> 1.0.0 |
| <a name="module_service_monitors"></a> [service\_monitors](#module\_service\_monitors) | c0x12c/monitors/datadog | ~> 1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apm_http_metric"></a> [apm\_http\_metric](#input\_apm\_http\_metric) | APM HTTP metric name for latency and error monitoring | `string` | `"trace.http.request"` | no |
| <a name="input_apm_service_name"></a> [apm\_service\_name](#input\_apm\_service\_name) | APM service name for trace metrics. Defaults to ecs\_service\_name if not specified | `string` | `null` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS account ID for metric filtering | `string` | n/a | yes |
| <a name="input_cpu_critical_max_threshold"></a> [cpu\_critical\_max\_threshold](#input\_cpu\_critical\_max\_threshold) | Maximum CPU threshold percentage for critical alerts (service\_cpu\_critical monitor) | `number` | `95` | no |
| <a name="input_cpu_critical_threshold"></a> [cpu\_critical\_threshold](#input\_cpu\_critical\_threshold) | CPU utilization critical threshold percentage for high alerts | `number` | `80` | no |
| <a name="input_cpu_warning_threshold"></a> [cpu\_warning\_threshold](#input\_cpu\_warning\_threshold) | CPU utilization warning threshold percentage | `number` | `70` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | ECS cluster name for filtering metrics | `string` | n/a | yes |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | ECS service name for filtering metrics. Use '*' to monitor all services in the cluster | `string` | `"*"` | no |
| <a name="input_enabled_monitors"></a> [enabled\_monitors](#input\_enabled\_monitors) | List of monitor categories to enable: service, apm, logs | `list(string)` | <pre>[<br/>  "service",<br/>  "apm"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_error_count_threshold"></a> [error\_count\_threshold](#input\_error\_count\_threshold) | Error count critical threshold (absolute number) | `number` | `10` | no |
| <a name="input_error_rate_threshold"></a> [error\_rate\_threshold](#input\_error\_rate\_threshold) | Error rate critical threshold percentage | `number` | `1` | no |
| <a name="input_escalate_min_priority"></a> [escalate\_min\_priority](#input\_escalate\_min\_priority) | Minimum priority level for escalating to @channel in Slack. Only monitors with priority\_level <= this value will tag @channel. P1=1 (Critical), P2=2 (High), P3=3 (Medium). Set to 0 to escalate all priorities, or 2 to skip escalating P3 issues | `number` | `0` | no |
| <a name="input_log_critical_error_threshold"></a> [log\_critical\_error\_threshold](#input\_log\_critical\_error\_threshold) | Critical error count threshold (5xx, fatal, panic) in 10min window | `number` | `5` | no |
| <a name="input_log_error_count_threshold"></a> [log\_error\_count\_threshold](#input\_log\_error\_count\_threshold) | Log error count threshold for spike detection (absolute number in 15min window) | `number` | `50` | no |
| <a name="input_log_sustained_error_threshold"></a> [log\_sustained\_error\_threshold](#input\_log\_sustained\_error\_threshold) | Sustained error count threshold over 1 hour window | `number` | `100` | no |
| <a name="input_memory_critical_max_threshold"></a> [memory\_critical\_max\_threshold](#input\_memory\_critical\_max\_threshold) | Maximum memory threshold percentage for critical alerts (service\_memory\_critical monitor) | `number` | `95` | no |
| <a name="input_memory_critical_threshold"></a> [memory\_critical\_threshold](#input\_memory\_critical\_threshold) | Memory utilization critical threshold percentage for high alerts | `number` | `80` | no |
| <a name="input_memory_warning_threshold"></a> [memory\_warning\_threshold](#input\_memory\_warning\_threshold) | Memory utilization warning threshold percentage | `number` | `70` | no |
| <a name="input_notification_slack_channel_prefix"></a> [notification\_slack\_channel\_prefix](#input\_notification\_slack\_channel\_prefix) | Slack channel prefix for notifications (e.g., 'alerts-' results in 'alerts-prod') | `string` | n/a | yes |
| <a name="input_override_default_monitors"></a> [override\_default\_monitors](#input\_override\_default\_monitors) | Override default monitor configurations. Keys are monitor names, values are maps of attributes to override | `map(map(any))` | `{}` | no |
| <a name="input_p95_latency_threshold"></a> [p95\_latency\_threshold](#input\_p95\_latency\_threshold) | P95 latency critical threshold in seconds | `number` | `1` | no |
| <a name="input_p99_latency_threshold"></a> [p99\_latency\_threshold](#input\_p99\_latency\_threshold) | P99 latency critical threshold in seconds. Defaults to 3x p95\_latency\_threshold if not specified | `number` | `null` | no |
| <a name="input_recovery_threshold_ratio"></a> [recovery\_threshold\_ratio](#input\_recovery\_threshold\_ratio) | Ratio for calculating recovery thresholds from critical thresholds (0.0-1.0). E.g., 0.8 means recovery at 80% of critical threshold | `number` | `0.8` | no |
| <a name="input_renotify_interval_critical"></a> [renotify\_interval\_critical](#input\_renotify\_interval\_critical) | Renotification interval in minutes for critical (P1) monitors | `number` | `15` | no |
| <a name="input_renotify_interval_high"></a> [renotify\_interval\_high](#input\_renotify\_interval\_high) | Renotification interval in minutes for high priority (P2) monitors | `number` | `30` | no |
| <a name="input_renotify_interval_medium"></a> [renotify\_interval\_medium](#input\_renotify\_interval\_medium) | Renotification interval in minutes for medium priority (P3) monitors | `number` | `60` | no |
| <a name="input_tag_slack_channel"></a> [tag\_slack\_channel](#input\_tag\_slack\_channel) | Whether to tag the Slack channel (@channel) in notifications | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apm_monitor_names"></a> [apm\_monitor\_names](#output\_apm\_monitor\_names) | List of created APM monitor names |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | ECS cluster name being monitored |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | ECS service name being monitored |
| <a name="output_enabled_monitors"></a> [enabled\_monitors](#output\_enabled\_monitors) | List of enabled monitor categories |
| <a name="output_log_monitor_names"></a> [log\_monitor\_names](#output\_log\_monitor\_names) | List of created log monitor names |
| <a name="output_service_monitor_names"></a> [service\_monitor\_names](#output\_service\_monitor\_names) | List of created service monitor names |
<!-- END_TF_DOCS -->
