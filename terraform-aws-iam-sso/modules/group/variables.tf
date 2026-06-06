variable "group_name" {
  description = "The name of the IAM SSO group to be created."
  type        = string
}

variable "aws_accounts" {
  description = "A map of AWS account IDs to their respective permission set ARNs. Each key is an AWS account ID, and the value is another map where the keys are permission set names and values are their ARNs."
  type        = map(map(string))
}

variable "users" {
  description = "A map of users to be added to the IAM SSO group. Each key is a user email address, and the value is an object that contains the user's first name, last name, and username."
  type = map(object({
    first_name = string
    last_name  = string
    user_name  = string
  }))
  default = {}
}
