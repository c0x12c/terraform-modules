variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "environment" {
  description = "The environment monitored by this module"
  type        = string
}

variable "db_name_regex" {
  description = "Define database name to filter by datadog monitors, it will collects multiple datase in case it is `*`"
  type        = string
  default     = "*"
}

variable "service_name" {
  description = "Service tag to filter RDS query (trace) monitors by. `*` matches all services."
  type        = string
  default     = "*"
}

variable "notification_slack_channel_prefix" {
  description = "The prefix for Slack channels that will receive notifications and alerts"
  type        = string
}

variable "override_default_monitors" {
  type    = any
  default = {}

  # Deliberately `any` rather than `map(map(any))`: the inner `map(any)` forces
  # every value within a single monitor to unify to one type, so a nested
  # attribute such as `query_args` cannot be overridden alongside a scalar like
  # `override_default_message`. That made `query_args` unreachable for callers.
  # The validation below keeps the shape guarantee the old type provided.
  validation {
    condition = can(keys(var.override_default_monitors)) && alltrue([
      for _, monitor in var.override_default_monitors : can(keys(monitor))
    ])
    error_message = "override_default_monitors must be a map of monitor name => map of attributes."
  }

  description = <<-EOT
    Override default monitors with custom configuration. Values are merged over the
    module defaults, so only the attributes you want to change need to be set.

    Nested attributes are supported, e.g. widening a monitor's evaluation window
    without restating its query:

    ```
    msk_active_controller = {
      override_default_message = "..."
      query_args               = { timeframe = "last_15m" }
    }
    ```
  EOT
}

variable "tag_slack_channel" {
  description = "Whether to tag the Slack channel in the message"
  type        = bool
  default     = true
}

variable "enabled_modules" {
  description = "List of modules to enable, must be one of billing, elasticache, rds"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for module_name in var.enabled_modules : contains(["billing", "elasticache", "msk", "rds", "airflow", "emr", "kinesis"], module_name)])
    error_message = "Invalid module name, must be one of billing, elasticache, msk, rds, airflow, emr, kinesis"
  }
}
