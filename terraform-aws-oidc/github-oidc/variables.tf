# Provider

variable "additional_thumbprints" {
  description = "List of additional thumbprints to add to the thumbprint list. Reference: https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/."
  type        = list(string)
  default = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

variable "client_id_list" {
  description = "List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided."
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "url" {
  description = "The URL of the identity provider. Corresponds to the iss claim."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

# GitHub

variable "role_policy_arns" {
  description = "List of ARNs of IAM policies to attach to IAM role"
  type        = list(string)
  default     = []
}

variable "role_name" {
  description = "The name of the role to be created."
  type        = string
}

variable "role_name_prefix" {
  description = "The name of the role to be created."
  type        = string
  default     = ""
}

variable "repository_path" {
  description = "The path to the repository (organization/repo_name)."
  type        = string
}

variable "conditions" {
  description = "(Optional) Additonal conditions for checking the OIDC claim."
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []
}

# migration

variable "create_provider" {
  description = "Whether to create a provider resource for migration purpose on existing provider."
  type        = bool
  default     = false
}
