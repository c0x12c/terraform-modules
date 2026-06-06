variable "team_name" {
  description = "The name of the Datadog team."
  type        = string
}

variable "team_description" {
  description = "A description for the Datadog team."
  type        = string
}

variable "team_handle" {
  description = "The handle for the Datadog team, which must be unique."
  type        = string
}

variable "team_members" {
  description = "A list of email addresses for the users to be added to the team."
  type        = list(string)
}