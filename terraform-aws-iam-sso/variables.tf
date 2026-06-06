variable "groups" {
  description = "A map of IAM SSO groups, their users, AWS accounts, and permission sets."
  type = map(object({
    # Map of AWS account IDs to permission set ARNs
    aws_accounts = optional(map(map(string)))
    users = optional(
      map(
        object({
          first_name = string
          last_name  = string
          user_name  = string
        })
      )
    )
  }))
  default = {}
}
