variable "name" {
  description = "The name of the SNS topic to be created."
  type        = string
}

variable "subscriptions" {
  description = <<EOT
A list of subscription objects specifying details for each subscription.
Each subscription object must contain:
  - `name`: A unique name for the subscription.
  - `protocol`: The protocol to use for the subscription (e.g., "email", "https").
  - `endpoint`: The endpoint to send notifications to (e.g., an email address or a URL).
EOT
  type = list(object({
    name     = string
    protocol = string,
    endpoint = string,
  }))
}
