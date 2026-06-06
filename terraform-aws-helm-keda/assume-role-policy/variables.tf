variable "keda_operator_role_id" {
  description = "The ID of the IAM role that Keda will use to access AWS resources."
  type        = string
}

variable "assume_role_arns" {
  description = "A list of ARNs that Keda will use to assume the IAM role to access AWS resources."
  type        = list(string)
  default     = []
}
