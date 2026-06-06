variable "region" {
  type        = string
  description = "Region where the resources will be created"
  default     = null
}

variable "name" {
  type        = string
  description = "Name of the resources will be created"
}

variable "fargate_profile_pod_execution_role_name" {
  type        = string
  description = "The name of the IAM role used by Fargate to execute pods in the EKS cluster"
}
