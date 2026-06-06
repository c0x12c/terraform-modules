variable "domain" {
  description = "The domain associated with the Google Workspace account."
  type        = string
}

variable "groups" {
  description = "A map of Google Workspace groups, where each group has a description, a name, and a list of member email addresses. This configuration allows for dynamic management of multiple groups and their members."
  type = map(object({
    description = string
    name        = string
    members     = list(string)
  }))
}
