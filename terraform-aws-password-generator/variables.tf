variable "password_length" {
  description = "The length of password to generate."
  type        = number
  default     = 32
}

variable "secret_name" {
  description = "The name of the secret"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
