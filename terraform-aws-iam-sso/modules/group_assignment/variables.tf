variable "aws_account_id" {
  description = "The AWS account ID to which the IAM SSO group will be assigned."
  type        = string
}

variable "group_id" {
  description = "The ID of the IAM SSO group to assign to the AWS account."
  type        = string
}

variable "permission_set_arns" {
  description = "A map of permission set names to their corresponding ARN values. Each key represents a permission set name and each value is the ARN for that permission set."
  type        = map(string)
}
