resource "datadog_monitor" "http_5xx" {
  count = var.http_5xx != null ? 1 : 0

  type = "trace-analytics alert"
  tags = [
    "created_by:terraform",
    "env:${var.environment}",
    "service:${var.http_5xx.service_regex}"
  ]

  query    = "trace-analytics(\"env:${var.environment} @http.status_code:5* service:${var.http_5xx.service_regex} ${var.http_5xx.additional_filter_regex}\").rollup(\"count\").by(\"service,env,resource_name\").last(\"${var.http_5xx.time_window}\") > ${var.http_5xx.critical}"
  name     = var.http_5xx.name
  priority = var.http_5xx.priority
  message  = var.http_5xx.message

  monitor_thresholds {
    critical          = var.http_5xx.critical
    critical_recovery = var.http_5xx.critical_recovery
  }

  require_full_window = var.require_full_window
}

resource "datadog_monitor" "http_4xx" {
  count = var.http_4xx != null ? 1 : 0

  type = "trace-analytics alert"
  tags = [
    "created_by:terraform",
    "env:${var.environment}",
    "service:${var.http_4xx.service_regex}"
  ]

  query    = "trace-analytics(\"env:${var.environment} @http.status_code:4* service:${var.http_4xx.service_regex} ${var.http_4xx.additional_filter_regex}\").rollup(\"count\").by(\"service,env,resource_name\").last(\"${var.http_4xx.time_window}\") > ${var.http_4xx.critical}"
  name     = var.http_4xx.name
  priority = var.http_4xx.priority
  message  = var.http_4xx.message

  monitor_thresholds {
    critical          = var.http_4xx.critical
    critical_recovery = var.http_4xx.critical_recovery
  }

  require_full_window = var.require_full_window
}

resource "datadog_monitor" "high_number_of_errors" {
  count = var.high_number_of_errors != null ? 1 : 0

  type = "error-tracking alert"
  tags = [
    "created_by:terraform",
    "env:${var.environment}",
    "service:${var.high_number_of_errors.service_regex}"
  ]

  query    = <<EOT
error-tracking("env:${var.environment} service:${var.high_number_of_errors.service_regex} ${var.high_number_of_errors.additional_filter_regex}").source("${var.high_number_of_errors.source}").impact().rollup("count").by("issue.id").last("${var.high_number_of_errors.time_window}") > ${var.high_number_of_errors.critical}
EOT
  name     = var.high_number_of_errors.name
  priority = var.high_number_of_errors.priority
  message  = var.high_number_of_errors.message

  monitor_thresholds {
    critical          = var.high_number_of_errors.critical
    critical_recovery = var.high_number_of_errors.critical_recovery
  }

  require_full_window = var.require_full_window
}

resource "datadog_monitor" "new_issue" {
  count = var.new_issue != null ? 1 : 0

  type = "error-tracking alert"
  tags = [
    "created_by:terraform",
    "env:${var.environment}",
    "service:${var.new_issue.service_regex}"
  ]

  query    = <<EOT
error-tracking("env:${var.environment} service:${var.new_issue.service_regex} ${var.new_issue.additional_filter_regex}").source("${var.new_issue.source}").new().rollup("count").by("issue.id").last("${var.new_issue.time_window}") > ${var.new_issue.critical}
EOT
  name     = var.new_issue.name
  priority = var.new_issue.priority
  message  = var.new_issue.message

  monitor_thresholds {
    critical          = var.new_issue.critical
    critical_recovery = var.new_issue.critical_recovery
  }

  require_full_window = var.require_full_window
}
