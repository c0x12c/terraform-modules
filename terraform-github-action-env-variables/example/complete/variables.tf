variable "github_token" {
  description = "GitHub personal access token with repo permissions"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub organization or user account"
  type        = string
  default     = "c0x12c"
}
