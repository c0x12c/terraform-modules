variable "description" {
  description = "The description for the Google Workspace group."
  type        = string
  default     = null
}

variable "domain" {
  description = "The domain associated with the Google Workspace group."
  type        = string
}

variable "identifier" {
  description = "The unique identifier (such as a group name or alias) used to create the email address for the Google Workspace group. Combined with the domain, it forms the full email address of the group."
  type        = string
}

variable "members" {
  description = "A list of email address prefix (without domain) representing the members to be added to the Google Workspace group."
  type        = list(string)
  default     = []
}

variable "name" {
  description = "The name of the Google Workspace group. This name will be used to identify the group in the Google Workspace Admin Console."
  type        = string
}
