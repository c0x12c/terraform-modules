variable "identity_store_id" {
  description = "The identity store ID associated with your AWS Single Sign-On (SSO) instance."
  type        = string
}

variable "email" {
  description = "The email address of the user to be added to the IAM SSO group."
  type        = string
}

variable "first_name" {
  description = "The first name of the user to be added to the IAM SSO group."
  type        = string
}

variable "last_name" {
  description = "The last name of the user to be added to the IAM SSO group."
  type        = string
}

variable "user_name" {
  description = "The username of the user to be added to the IAM SSO group."
  type        = string
}
