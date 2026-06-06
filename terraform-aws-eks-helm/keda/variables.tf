variable "chart_version" {
  description = "The version of the Keda Helm chart being deployed."
  type        = string
  default     = "2.16.1"
}

variable "helm_release_name" {
  description = "The name of the Helm release for the Keda deployment."
  type        = string
  default     = "keda"
}

variable "namespace" {
  description = "The Kubernetes namespace where Keda will be installed. Defaults to 'keda'."
  type        = string
  default     = "keda"
}

variable "enabled_aws_irsa" {
  description = "Option to enable or disable the AWS IAM Roles for Service Accounts (IRSA)."
  type        = bool
  default     = true
}

variable "oidc_provider" {
  type = object({
    arn = string
    url = string
  })
  description = "The OIDC provider which are related to the cluster and is used for IRSA."
}

variable "keda_operator_role_name" {
  description = "The name of the IAM role that Keda will use to access AWS resources."
  type        = string
  default     = "keda-operator"
}

variable "operator_cpu" {
  description = "The amount of CPU resources allocated to the operator."
  type        = string
  default     = "100m"
}

variable "operator_memory" {
  description = "The amount of memory resources allocated to the operator."
  type        = string
  default     = "256Mi"
}

variable "metric_server_cpu" {
  description = "The amount of CPU resources allocated to the metric server."
  type        = string
  default     = "50m"
}

variable "metric_server_memory" {
  description = "The amount of memory resources allocated to the metric server."
  type        = string
  default     = "64Mi"
}

variable "admission_webhook_server_cpu" {
  description = "The amount of CPU resources allocated to the admission webhook server."
  type        = string
  default     = "50m"
}

variable "admission_webhook_server_memory" {
  description = "The amount of memory resources allocated to the admission webhook server."
  type        = string
  default     = "64Mi"
}

variable "node_selector" {
  description = "Node selector for the keda"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for the keda"
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = optional(string)
  }))
  default = []
}
