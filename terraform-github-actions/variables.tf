variable "repository_secrets" {
  description = "A map of maps of repository and GitHub Actions secrets."
  type        = map(map(string))
  default     = {}
}

variable "repository_variables" {
  description = "A map of maps of repository and GitHub Actions variables."
  type        = map(map(string))
  default     = {}
}
