variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "user_groups" {
  description = "A map of user groups: including associating members and roles."
  type = map(object({
    members = list(string)
    roles   = list(string)
  }))
  default = {}
}
