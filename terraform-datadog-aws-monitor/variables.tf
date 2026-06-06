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

variable "notification_slack_channel_prefix" {
  description = "The prefix for Slack channels that will receive notifications and alerts"
  type        = string
}

variable "override_default_monitors" {
  type        = map(map(any))
  default     = {}
  description = "Override default monitors with custom configuration"
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
