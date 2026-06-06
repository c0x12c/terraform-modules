variable "aws_account_id" {
  description = "AWS account ID for metric filtering"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS account ID must be a 12-digit number"
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for filtering metrics"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name for filtering metrics. Use '*' to monitor all services in the cluster"
  type        = string
  default     = "*"
}

variable "notification_slack_channel_prefix" {
  description = "Slack channel prefix for notifications (e.g., 'alerts-' results in 'alerts-prod')"
  type        = string
}

variable "tag_slack_channel" {
  description = "Whether to tag the Slack channel (@channel) in notifications"
  type        = bool
  default     = true
}

variable "escalate_min_priority" {
  description = "Minimum priority level for escalating to @channel in Slack. Only monitors with priority_level <= this value will tag @channel. P1=1 (Critical), P2=2 (High), P3=3 (Medium). Set to 0 to escalate all priorities, or 2 to skip escalating P3 issues"
  type        = number
  default     = 0

  validation {
    condition     = var.escalate_min_priority >= 0 && var.escalate_min_priority <= 3
    error_message = "Minimum priority level must be between 0 (escalate all) and 3 (P3 only)"
  }
}

variable "enabled_monitors" {
  description = "List of monitor categories to enable: service, apm, logs"
  type        = list(string)
  default     = ["service", "apm"]

  validation {
    condition     = alltrue([for m in var.enabled_monitors : contains(["service", "apm", "logs"], m)])
    error_message = "Valid monitor categories: service, apm, logs"
  }
}

variable "override_default_monitors" {
  description = "Override default monitor configurations. Keys are monitor names, values are maps of attributes to override"
  type        = map(map(any))
  default     = {}
}

# APM Configuration
variable "apm_service_name" {
  description = "APM service name for trace metrics. Defaults to ecs_service_name if not specified"
  type        = string
  default     = null
}

variable "apm_http_metric" {
  description = "APM HTTP metric name for latency and error monitoring"
  type        = string
  default     = "trace.http.request"
}

# Threshold Configuration
variable "recovery_threshold_ratio" {
  description = "Ratio for calculating recovery thresholds from critical thresholds (0.0-1.0). E.g., 0.8 means recovery at 80% of critical threshold"
  type        = number
  default     = 0.8

  validation {
    condition     = var.recovery_threshold_ratio > 0 && var.recovery_threshold_ratio < 1
    error_message = "Recovery threshold ratio must be between 0 and 1 (exclusive)"
  }
}

variable "cpu_critical_threshold" {
  description = "CPU utilization critical threshold percentage for high alerts"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_critical_threshold > 0 && var.cpu_critical_threshold <= 100
    error_message = "CPU critical threshold must be between 0 and 100"
  }
}

variable "cpu_warning_threshold" {
  description = "CPU utilization warning threshold percentage"
  type        = number
  default     = 70

  validation {
    condition     = var.cpu_warning_threshold > 0 && var.cpu_warning_threshold <= 100
    error_message = "CPU warning threshold must be between 0 and 100"
  }
}

variable "cpu_critical_max_threshold" {
  description = "Maximum CPU threshold percentage for critical alerts (service_cpu_critical monitor)"
  type        = number
  default     = 95

  validation {
    condition     = var.cpu_critical_max_threshold > 0 && var.cpu_critical_max_threshold <= 100
    error_message = "CPU critical max threshold must be between 0 and 100"
  }
}

variable "memory_critical_threshold" {
  description = "Memory utilization critical threshold percentage for high alerts"
  type        = number
  default     = 80

  validation {
    condition     = var.memory_critical_threshold > 0 && var.memory_critical_threshold <= 100
    error_message = "Memory critical threshold must be between 0 and 100"
  }
}

variable "memory_warning_threshold" {
  description = "Memory utilization warning threshold percentage"
  type        = number
  default     = 70

  validation {
    condition     = var.memory_warning_threshold > 0 && var.memory_warning_threshold <= 100
    error_message = "Memory warning threshold must be between 0 and 100"
  }
}

variable "memory_critical_max_threshold" {
  description = "Maximum memory threshold percentage for critical alerts (service_memory_critical monitor)"
  type        = number
  default     = 95

  validation {
    condition     = var.memory_critical_max_threshold > 0 && var.memory_critical_max_threshold <= 100
    error_message = "Memory critical max threshold must be between 0 and 100"
  }
}

variable "p95_latency_threshold" {
  description = "P95 latency critical threshold in seconds"
  type        = number
  default     = 1
}

variable "p99_latency_threshold" {
  description = "P99 latency critical threshold in seconds. Defaults to 3x p95_latency_threshold if not specified"
  type        = number
  default     = null
}

variable "error_rate_threshold" {
  description = "Error rate critical threshold percentage"
  type        = number
  default     = 1
}

variable "error_count_threshold" {
  description = "Error count critical threshold (absolute number)"
  type        = number
  default     = 10
}

variable "log_error_count_threshold" {
  description = "Log error count threshold for spike detection (absolute number in 15min window)"
  type        = number
  default     = 50

  validation {
    condition     = var.log_error_count_threshold > 0
    error_message = "Log error count threshold must be positive"
  }
}

variable "log_critical_error_threshold" {
  description = "Critical error count threshold (5xx, fatal, panic) in 10min window"
  type        = number
  default     = 5

  validation {
    condition     = var.log_critical_error_threshold >= 0
    error_message = "Log critical error threshold must be non-negative"
  }
}

variable "log_sustained_error_threshold" {
  description = "Sustained error count threshold over 1 hour window"
  type        = number
  default     = 100

  validation {
    condition     = var.log_sustained_error_threshold > 0
    error_message = "Log sustained error threshold must be positive"
  }
}

# Renotification Configuration
variable "renotify_interval_critical" {
  description = "Renotification interval in minutes for critical (P1) monitors"
  type        = number
  default     = 15
}

variable "renotify_interval_high" {
  description = "Renotification interval in minutes for high priority (P2) monitors"
  type        = number
  default     = 30
}

variable "renotify_interval_medium" {
  description = "Renotification interval in minutes for medium priority (P3) monitors"
  type        = number
  default     = 60
}
