variable "name" {
  description = "The base name for resources, used to create unique resource identifiers."
  type        = string
}

variable "sqs_arn" {
  description = "The ARN of the target SQS queue where messages will be sent."
  type        = string
}

variable "message_body" {
  description = "The content of the message body"
  type        = string
}

variable "queue_url" {
  description = "The URL of the SQS queue"
  type        = string
}

variable "schedule_expression" {
  description = "A cron schedule expression defining when the task runs"
  type        = string
}

variable "schedule_expression_timezone" {
  description = "(Optional) Timezone in which the scheduling expression is evaluated. Defaults to UTC"
  default     = null
  type        = string
}
