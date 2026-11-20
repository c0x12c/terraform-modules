variable "notification_rules" {
  description = "Datadog notification rules. `filter.tags` ANDs key:value tags; `filter.scope` is a boolean expression (AND, OR, NOT, parentheses), e.g. `env:dev AND NOT team:x`."
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
