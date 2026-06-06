# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-02-04

### Added

- `escalate_min_priority` variable to control minimum priority level for @channel escalation
  - Set to `0` (default) to escalate all priority levels
  - Set to `2` to only escalate P1 (Critical) and P2 (High) alerts, skipping P3 (Medium) alerts like throughput drops
  - Works in combination with `tag_slack_channel` boolean flag
  - Provides granular control over Slack channel notifications per monitor priority

## [1.0.2] - 2026-01-18

### Changed

- Added environment filter to all log monitors to ensure proper isolation:
  - `log_error_spike` - Now includes `env:${var.environment}` filter
  - `log_critical_errors` - Now includes `env:${var.environment}` filter
  - `log_sustained_errors` - Now includes `env:${var.environment}` filter

## [1.0.1] - 2024-12-12

### Added

- Log monitors for error detection:
  - `log_error_spike` - High volume of error logs in 15min window (P2)
  - `log_critical_errors` - Critical error detection for 5xx, fatal, panic (P1)
  - `log_sustained_errors` - Sustained high error volume over 1 hour (P2)
- New variables for log monitor thresholds:
  - `log_error_count_threshold` - Default 50 errors in 15min
  - `log_critical_error_threshold` - Default 5 errors in 10min
  - `log_sustained_error_threshold` - Default 100 errors in 1 hour

## [1.0.0] - 2024-12-12

### Added

- Initial release of terraform-datadog-ecs-monitor module
- ECS Service monitors:
  - `service_cpu_high` - High CPU utilization alert (P2)
  - `service_cpu_critical` - Critical CPU utilization alert (P1)
  - `service_memory_high` - High memory utilization alert (P2)
  - `service_memory_critical` - Critical memory utilization alert (P1)
  - `service_running_tasks_low` - Running tasks below desired count (P1)
  - `service_task_count_zero` - Service down alert (P1)
  - `service_pending_tasks_stuck` - Tasks stuck in pending state (P2)
- ECS Cluster monitors (EC2 launch type only):
  - `cluster_cpu_reservation_high` - High CPU reservation (P2)
  - `cluster_memory_reservation_high` - High memory reservation (P2)
  - `cluster_cpu_utilization_high` - High cluster CPU utilization (P2)
  - `cluster_memory_utilization_high` - High cluster memory utilization (P2)
- APM monitors:
  - `apm_p95_latency` - P95 latency alert (P3)
  - `apm_p99_latency` - P99 latency alert (P2)
  - `apm_error_rate` - Error rate alert (P2)
  - `apm_error_count` - Error count spike alert (P2)
  - `apm_throughput_drop` - Request throughput drop detection (P3)
- Configurable thresholds for CPU, memory, latency, and error metrics
- Support for monitoring all services in a cluster using wildcard
- Override capability for individual monitor configurations
- Slack notification integration with configurable channel prefix
