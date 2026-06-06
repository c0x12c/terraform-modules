# general
variable "name" {
  description = "The metric identifier."
  type        = string
}

# metric
variable "description" {
  description = "A description of this metric, which is used in documentation. The maximum length of the description is 8000 characters."
  type        = string
  default     = null
}

variable "filter" {
  description = "An advanced logs filter (https://cloud.google.com/logging/docs/view/advanced-filters) which is used to match log entries."
  type        = string
}

variable "metric_kind" {
  description = "Whether the metric records instantaneous values, changes to a value, etc. Some combinations of metricKind and valueType might not be supported. For counter metrics, set this to DELTA. Possible values are: DELTA, GAUGE, CUMULATIVE."
  type        = string
  validation {
    condition     = contains(["DELTA", "GAUGE", "CUMULATIVE"], var.metric_kind)
    error_message = "Possible values are: DELTA, GAUGE, CUMULATIVE"
  }
}

variable "value_type" {
  description = "Whether the measurement is an integer, a floating-point number, etc. Some combinations of metricKind and valueType might not be supported. For counter metrics, set this to INT64. Possible values are: BOOL, INT64, DOUBLE, STRING, DISTRIBUTION, MONEY."
  type        = string
  validation {
    condition     = contains(["BOOL", "INT64", "DOUBLE", "STRING", "DISTRIBUTION", "MONEY"], var.value_type)
    error_message = "Possible values are: BOOL, INT64, DOUBLE, STRING, DISTRIBUTION, MONEY."
  }
}

variable "unit" {
  description = "The unit in which the metric value is reported. It is only applicable if the valueType is INT64, DOUBLE, or DISTRIBUTION."
  type        = string
  default     = null
}

# alert
variable "combiner" {
  description = "How to combine the results of multiple conditions to determine if an incident should be opened. Valid values: AND, OR, AND_WITH_MATCHING_RESOURCE."
  type        = string
}

variable "resource_type" {
  description = ""
  type        = string
  default     = null
}

variable "conditions" {
  description = <<EOT
List of conditions to include in the alert policy. Each condition defines how a specific metric should be monitored.
- display_name – Name of the condition.
- comparison – The comparison to apply between the time series and the threshold (e.g., COMPARISON_GT).
- threshold_value – The value against which to compare the metric.
- duration – The length of time that a time series must violate the threshold to be considered failing.
EOT

  type = list(object({
    display_name    = string
    comparison      = string
    threshold_value = number
    duration        = string
  }))
}

variable "auto_close" {
  description = "If an alert policy that was active has no data for this long, any open incidents will close. Must be a valid duration (e.g., \"300s\")."
  type        = string
  default     = "1800s"
}

variable "notification_channels" {
  description = "Identifiers of the notification channels to use for this alert. Each channel must already exist in the project."
  type        = list(string)
  default     = null
}

variable "user_labels" {
  description = "A set of custom labels for the alert policy. Label keys and values can be used to organize and identify alert policies."
  type        = map(string)
  default     = null
}
