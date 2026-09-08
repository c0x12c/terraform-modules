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
  type        = any
  default     = {}
  description = "Per-monitor overrides merged onto the module defaults, keyed by monitor name. Only the attributes that change need to appear. The type is any rather than a nested map because Terraform resolves any to a single type across the whole value, so map(map(any)) cannot hold an additional_tags list alongside a numeric threshold or a bool enabled."

  validation {
    # `any` is what lets one entry carry an additional_tags list beside a numeric threshold, but it
    # also lets a wrong shape through to try(var.override_default_monitors[name], {}), where
    # indexing a list or a scalar by a monitor name errors and try() swallows it - the override is
    # then silently ignored rather than rejected. This checks the shape without constraining the
    # value types.
    condition     = can([for e in values(var.override_default_monitors) : keys(e)])
    error_message = "override_default_monitors must be a map keyed by monitor name whose values are maps of monitor attributes."
  }
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
