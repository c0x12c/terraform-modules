variable "secret_prefix" {
  description = "The prefix of your secret name in format '{secret_prefix}-{secret_key}'."
  type        = string
  default     = null
}

variable "secrets" {
  description = "A map of secrets to be stored in AWS Secrets Manager and passed into the application."
  type        = map(string)
}
