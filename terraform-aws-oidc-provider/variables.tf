variable "additional_thumbprints" {
  description = "List of additional thumbprints to add to the thumbprint list."
  type        = list(string)
  default     = []
}

variable "client_id_list" {
  description = "List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided"
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "url" {
  description = "The URL of the identity provider. Corresponds to the iss claim"
  type        = string
}

variable "create_provider" {
  description = "Whether to create a provider resource for migration purpose on existing provider."
  type        = bool
  default     = false
}
