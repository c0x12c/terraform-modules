variable "notification_rules" {
  description = "Datadog notification rules. filter.tags ANDs tags; filter.scope takes AND, OR, NOT."
  type = map(object({
    name       = string
    recipients = list(string)
    filter = optional(object({
      tags  = optional(list(string))
      scope = optional(string)
    }))
  }))

  default = {}
}
