variable "monitors" {
  type = map(object({
    enabled                     = optional(bool, true)
    priority_level              = number
    title_tags                  = string
    title                       = string
    override_default_message    = optional(string, null)
    type                        = optional(string, "query alert")
    query_template              = string
    query_args                  = optional(map(string), {})
    threshold_critical          = number
    threshold_critical_recovery = optional(number, null)
    threshold_ok                = optional(number, null)
    threshold_warning           = optional(number, null)
    threshold_warning_recovery  = optional(number, null)
    renotify_interval           = number
    renotify_occurrences        = optional(number)
    require_full_window         = optional(bool, true)
    enabled_include_tags        = optional(bool, false)
    additional_tags             = optional(list(string), [])
    notification_preset_name    = optional(string, "hide_all")
  }))
  description = <<EOF
    A map of monitors to create. The key is the monitor name and the value is a map of monitor attributes. The following attributes are required:
    - enabled: Whether the monitor is enabled.
    - priority_level: The priority level of the monitor.
    - title_tags: The tags to include in the title of the monitor.
    - title: The title of the monitor.
    - override_default_message: An optional message to override the default slack mention.
    - type: The type of the monitor.
    - query_template: The template for the monitor query.
    - query_args: The arguments for the monitor query.
    - threshold_critical: The critical threshold for the monitor.
    - threshold_critical_recovery: The critical recovery threshold for the monitor.
    - threshold_ok: The recovery threshold for the monitor. Only supported in monitor type `service check`.
    - threshold_warning: The monitor WARNING threshold.
    - threshold_warning_recovery: The monitor WARNING recovery threshold.
    - renotify_interval: The renotify interval for the monitor.

    The following attributes are optional:
    - renotify_occurrences: The renotify occurrences for the monitor.
    - require_full_window: Whether the monitor requires a full window.
    - enabled_include_tags: Whether to include tags in the monitor.
    - additional_tags: Additional tags to include in the monitor.
    - notification_preset_name: The notification preset name for the monitor.
  EOF
}

variable "notification_slack_channel_prefix" {
  type        = string
  description = "The prefix for the Slack channel used for notifications."
}

variable "environment" {
  type        = string
  description = "The environment in which the monitors are being created (e.g., dev, staging, prod)."
}

variable "tag_slack_channel" {
  type        = bool
  description = "Whether to tag the Slack channel in the notification message."
  default     = false
}

variable "service" {
  type        = string
  description = "The service to monitor."
}
