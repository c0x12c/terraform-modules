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

variable "create_environment" {
  description = "Whether to create the GitHub environment. Set to false if the environment already exists or if you don't have permissions to create it."
  type        = bool
  default     = true
}
