variable "repository" {
  description = "repository name"
  type        = string
}

variable "variables" {
  description = "variables to be set in the repository"
  type        = map(string)
}
