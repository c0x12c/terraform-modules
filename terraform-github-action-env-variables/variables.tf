variable "repository" {
  description = "Name of the GitHub repository"
  type        = string
}

variable "environment" {
  description = "Name of the GitHub environment (e.g., 'production', 'staging', 'development')"
  type        = string
}

variable "variables" {
  description = "Map of variables to be set in the repository environment. Key is the variable name, value is the variable value."
  type        = map(string)
}
