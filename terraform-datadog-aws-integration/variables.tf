variable "datadog_aws_integration_iam_role" {
  description = "Name of the IAM role used for integrating Datadog with AWS."
  type        = string
  default     = "DatadogAWSIntegrationRole"
}

variable "datadog_permissions" {
  description = "List of AWS IAM permissions required for Datadog integration with AWS services. Reference: https://docs.datadoghq.com/integrations/amazon_web_services/#aws-integration-iam-policy."
  type        = list(string)
  default     = null
}

variable "namespace_filters_include_only" {
  description = "Collect metrics only from these AWS CloudWatch namespaces (e.g. [\"AWS/ElastiCache\", \"AWS/RDS\"]). Mutually exclusive with namespace_filters_exclude_only. Reference: https://docs.datadoghq.com/integrations/#cat-aws."
  type        = list(string)
  default     = null
}

variable "namespace_filters_exclude_only" {
  description = "Exclude these AWS CloudWatch namespaces from metrics collection; all others are collected. Mutually exclusive with namespace_filters_include_only. Ignored when namespace_filters_include_only is set. Reference: https://docs.datadoghq.com/integrations/#cat-aws."
  type        = list(string)
  default     = null
}

variable "aws_attached_policy_arns" {
  description = "List of AWS policy ARNs to attach to the Datadog AWS integration IAM role (e.g. arn:aws:iam::aws:policy/SecurityAudit)."
  type        = list(string)
  default     = []
}

variable "extended_collection" {
  description = "Enable Datadog's extended resource collection, which allows additional resource tags and configuration information to be collected. Reference: https://docs.datadoghq.com/integrations/amazon_web_services/#resource-collection."
  type        = bool
  default     = false
}
