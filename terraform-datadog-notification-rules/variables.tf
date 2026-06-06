variable "notification_rules" {
  description = "Datadog notification rules"
  type = map(object({
    name       = string
    recipients = list(string)
    filter = optional(object({
      tags = optional(list(string))
    }))
  }))

  default = {}
}