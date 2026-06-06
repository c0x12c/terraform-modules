variable "custom_namespaces" {
  type        = list(string)
  description = "Custom namespaces to be created during initialization"
  default     = []
}

variable "access_entries" {
  description = "List of access entries for EKS access entries and policies"
  type = list(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string))
    type              = optional(string)
    policy_arn        = optional(string)
    namespaces        = optional(list(string))
    access_type       = optional(string, "cluster")
  }))
  default = []
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
