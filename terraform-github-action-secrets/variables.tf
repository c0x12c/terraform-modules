variable "repository" {
  description = "repository name"
  type        = string
}

variable "secrets" {
  description = "secrets to be set in the repository"
  type        = map(string)
}
