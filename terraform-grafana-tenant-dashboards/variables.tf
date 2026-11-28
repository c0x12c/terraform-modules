variable "project" {
  description = "Project name. Titles the parent folder and prefixes every dashboard uid."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.project))
    error_message = "project must be lowercase letters, digits and hyphens, starting with a letter or digit."
  }

  # Grafana rejects uids longer than 40 characters; fail at plan with the offending uid named.
  validation {
    condition = alltrue([
      for pair in setproduct(keys(var.environments), concat(var.enabled_presets, keys(var.extra_dashboards))) :
      length("${var.project}-${pair[0]}-${pair[1]}") <= 40
    ])
    error_message = "Every dashboard uid <project>-<env>-<preset> must be at most 40 characters. Shorten project, or the extra_dashboards names."
  }
}

variable "environments" {
  description = "Environments keyed by dev or prod. Dashboard constants use namespace, service_name, pod_regex and container (default spartan); aws_tag_project defaults to project."
  type = map(object({
    namespace       = string
    service_name    = string
    pod_regex       = string
    container       = optional(string, "spartan")
    aws_tag_project = optional(string)
  }))

  validation {
    condition     = alltrue([for env in keys(var.environments) : contains(["dev", "prod"], env)])
    error_message = "environments keys must be dev or prod."
  }
}

variable "enabled_presets" {
  description = "Presets to render for every environment: pods, runtime, elasticache, rds, uptime, red."
  type        = list(string)
  default     = ["pods", "runtime", "elasticache", "rds", "uptime", "red"]

  validation {
    condition     = alltrue([for p in var.enabled_presets : contains(["pods", "runtime", "elasticache", "rds", "uptime", "red"], p)])
    error_message = "enabled_presets entries must be one of pods, runtime, elasticache, rds, uptime, red."
  }
}

variable "dashboard_overrides" {
  description = "Per-dashboard overrides keyed by preset or extra dashboard name. title replaces the generated title, enabled = false drops the dashboard."
  type = map(object({
    title   = optional(string)
    enabled = optional(bool)
  }))
  default = {}
}

variable "extra_dashboards" {
  description = "Additional dashboards, name => dashboard JSON. Rendered for every environment like a preset."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for json in values(var.extra_dashboards) : can(jsondecode(json))])
    error_message = "extra_dashboards values must be valid JSON."
  }
}

variable "red_thresholds" {
  description = "Threshold lines on the red preset: p95 latency in seconds and 5xx ratio (0.05 = 5 percent)."
  type = object({
    p95_seconds = number
    error_ratio = number
  })
  default = {
    p95_seconds = 1
    error_ratio = 0.05
  }
}

variable "folder_uids" {
  description = "Existing folder uids to adopt instead of the generated ones: parent, and envs keyed by env."
  type = object({
    parent = optional(string)
    envs   = optional(map(string))
  })
  default = {}
}

variable "scrape_interval" {
  description = "Minimum query interval stamped on every panel and target that has targets, in every rendered dashboard (presets and extra_dashboards, including panels nested in rows), such as 1m. Grafana computes $__rate_interval as at least 4x the data source scrape interval; a data source shared by workloads scraped at different periods cannot carry one value, so the dashboard sets the minimum interval instead. Null leaves panels unchanged."
  type        = string
  default     = null

  validation {
    condition     = var.scrape_interval == null || can(regex("^[0-9]+(ms|s|m|h)$", var.scrape_interval))
    error_message = "scrape_interval must be a number followed by ms, s, m or h, such as 1m."
  }
}
