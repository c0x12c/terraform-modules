variable "environment" {
  description = "AWS environment you are deploying to. Will be appended to SNS topic and alarm name. (e.g. dev, prod)"
  type        = string
}

variable "datapoints_to_alarm" {
  description = "The number of datapoints that must be breaching to trigger the alarm."
  type        = number
  default     = null
}

variable "queue_name" {
  description = "The queue name of the SQS queue."
  type        = string
  default     = null
}

#=============================#
# SNS                         #
#=============================#
variable "create_sns_topic" {
  description = "Creates a SNS Topic if `true`."
  type        = bool
  default     = true
}

variable "sns_topic_arns" {
  description = "List of SNS topic ARNs to be used. If `create_sns_topic` is `true`, it merges the created SNS Topic by this module with this list of ARNs"
  type        = list(string)
  default     = []
}

variable "alarms" {
  description = "A map of alarms to create"
  type = map(object({
    name                = string
    description         = string
    comparison_operator = string
    evaluation_periods  = string
    metric_name         = string
    namespace           = string
    period              = string
    statistic           = string
    threshold           = number
    queue_name          = optional(string)
    alb_name            = optional(string)
    target_group_name   = optional(string)
    instance_id         = optional(string)
    auto_scaling_group  = optional(string)
    currency            = optional(string)
    linked_account      = optional(string)
    identifier          = optional(string)
  }))
}

variable "email" {
  type = string
}
