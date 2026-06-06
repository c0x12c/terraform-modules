variable "title" {
  type        = string
  description = "The title of the dashboard."
}

variable "layout_type" {
  type        = string
  description = "The layout type of the dashboard. Valid values are ordered, free."
}

variable "description" {
  type        = string
  description = "The description of the dashboard."
  default     = null
}

variable "template_variables" {
  type = list(object({
    name             = string
    available_values = optional(list(string), [])
    default          = optional(string, "*")
    prefix           = optional(string, null)
  }))
  description = "The list of template variables for this powerpack."
  default     = []
}

variable "notify_list" {
  type        = list(string)
  description = "The list of handles for the users to notify when changes are made to this dashboard."
  default     = []
}

variable "reflow_type" {
  type        = string
  description = "The reflow type of a new dashboard layout. Valid values are auto, fixed."
  default     = null
}

variable "widgets" {
  type        = any
  description = "The list of widgets to display on the dashboard."
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "The tags of dashboard"
  default     = []
}
