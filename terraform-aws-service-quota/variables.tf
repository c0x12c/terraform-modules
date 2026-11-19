variable "quotas" {
  description = <<-EOT
    Service quotas to manage in the provider's region, keyed by a stable name of your choice.
    `value` is the value you want AWS to apply. When adopting a quota that is already raised,
    set `value` to the currently applied value so the import submits no increase request.
    Never set a value below the applied one: AWS does not lower quotas through this API.
  EOT
  type = map(object({
    service_code = string
    quota_code   = string
    value        = number
  }))
  default = {}

  validation {
    condition     = alltrue([for quota in values(var.quotas) : can(regex("^L-[0-9A-F]{8}$", quota.quota_code))])
    error_message = "Each quota_code must match L-XXXXXXXX (eight uppercase hex characters), for example L-1216C47A."
  }

  validation {
    condition     = alltrue([for quota in values(var.quotas) : quota.value > 0])
    error_message = "Each value must be greater than zero."
  }
}
