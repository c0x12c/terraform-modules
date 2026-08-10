variable "name" {
  description = "Name prefix applied to created resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to all taggable resources."
  type        = map(string)
  default     = {}
}

################################################################################
# AWS Health event filter
################################################################################

variable "event_type_categories" {
  description = "Categories to forward: issue, accountNotification, scheduledChange, investigation. Empty forwards all."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for c in var.event_type_categories :
      contains(["issue", "accountNotification", "scheduledChange", "investigation"], c)
    ])
    error_message = "Valid categories are issue, accountNotification, scheduledChange and investigation."
  }
}

variable "services" {
  description = "AWS service codes to forward, e.g. EC2 or RDS. Empty forwards every service."
  type        = list(string)
  default     = []
}

variable "event_type_codes" {
  description = "Specific AWS Health event type codes to forward, e.g. AWS_EC2_INSTANCE_STORE_DRIVE_PERFORMANCE_DEGRADED. Empty forwards every code."
  type        = list(string)
  default     = []
}

variable "exclude_backup_events" {
  description = "Drop backup copies of other Regions' events. us-west-2 backs up all Regions and us-east-1 backs up us-west-2, so rules there see duplicates."
  type        = bool
  default     = false
}

variable "event_pattern" {
  description = "JSON-encoded event pattern that replaces the generated AWS Health pattern outright. Setting this ignores the filter inputs above."
  type        = string
  default     = null
}

################################################################################
# EventBridge Rule
################################################################################

variable "eventbridge_rule_name" {
  description = "Name of the EventBridge rule. Defaults to {name}-health-notification."
  type        = string
  default     = null
}

variable "eventbridge_rule_description" {
  description = "Description of the EventBridge rule."
  type        = string
  default     = "Forward AWS Health Dashboard events to the notification topic"
}

variable "event_bus_name" {
  description = "Event bus the rule attaches to. Defaults to the account's default bus, which is where AWS Health delivers."
  type        = string
  default     = null
}

variable "input_transformer" {
  description = "Optional input transformer applied before publishing to SNS. Chatbot needs the raw event, so leave null when a Chatbot channel is attached."
  type = object({
    input_paths    = map(string)
    input_template = string
  })
  default = null
}

################################################################################
# SNS Topic
################################################################################

variable "create_sns_topic" {
  description = "Whether to create the SNS topic. Set false to publish into an existing topic."
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "ARN of an existing SNS topic. Required when create_sns_topic is false."
  type        = string
  default     = null

  validation {
    condition     = var.create_sns_topic || var.sns_topic_arn != null
    error_message = "sns_topic_arn is required when create_sns_topic is false."
  }
}

variable "sns_topic_name" {
  description = "Name of the SNS topic to create. Defaults to {name}-health-notification."
  type        = string
  default     = null
}

variable "sns_kms_master_key_id" {
  description = "KMS key ID or alias used to encrypt the created SNS topic. Null leaves the topic unencrypted."
  type        = string
  default     = null
}

################################################################################
# Delivery - generic SNS subscriptions
################################################################################

variable "subscriptions" {
  description = "Plain SNS subscriptions keyed by name: email, https, lambda, sqs. Email stays pending until the recipient confirms."
  type = map(object({
    protocol             = string
    endpoint             = string
    raw_message_delivery = optional(bool, false)
    filter_policy        = optional(string)
    filter_policy_scope  = optional(string)
  }))
  default = {}
}

################################################################################
# Delivery - AWS Chatbot
################################################################################

variable "slack_channels" {
  description = "Chatbot Slack channel configs keyed by name. workspace_id is the Slack team ID from the console authorization."
  type = map(object({
    workspace_id                = string
    channel_id                  = string
    configuration_name          = optional(string)
    logging_level               = optional(string, "ERROR")
    guardrail_policy_arns       = optional(list(string), [])
    user_authorization_required = optional(bool, false)
    iam_role_arn                = optional(string)
  }))
  default = {}
}

################################################################################
# IAM Role for AWS Chatbot
################################################################################

variable "create_iam_role" {
  description = "Whether to create the shared IAM role assumed by AWS Chatbot. Ignored when no Chatbot channel is configured."
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name of the IAM role to create. Defaults to {name}-chatbot-role."
  type        = string
  default     = null
}

variable "iam_role_arn" {
  description = "ARN of an existing IAM role for AWS Chatbot, used by any channel that does not set its own iam_role_arn."
  type        = string
  default     = null
}

variable "iam_policy_arns" {
  description = "Managed policy ARNs attached to the created Chatbot role."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonQDeveloperAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]
}
