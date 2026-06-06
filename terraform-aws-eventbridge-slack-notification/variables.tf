variable "name" {
  description = "The name prefix for all resources"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for sending notifications"
  type        = string
  sensitive   = true
}

variable "lambda_source_file" {
  description = "Path to the Lambda function source file"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "nodejs22.x"
}

variable "lambda_environment_variables" {
  description = "Additional environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "additional_iam_policy_arns" {
  description = "Additional IAM policy ARNs to attach to the Lambda execution role"
  type        = map(string)
  default     = {}
}

variable "event_rules" {
  description = "List of EventBridge rule configurations"
  type = list(object({
    name          = string
    description   = string
    event_pattern = any
  }))
}
