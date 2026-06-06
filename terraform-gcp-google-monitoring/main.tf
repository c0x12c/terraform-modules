/**
https://registry.terraform.io/providers/hashicorp/google/6.37.0/docs/resources/logging_metric
 */
resource "google_logging_metric" "this" {
  name        = var.name
  description = var.description
  filter      = var.filter

  metric_descriptor {
    metric_kind = var.metric_kind
    value_type  = var.value_type
    unit        = var.unit
  }
}

/**
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy
 */
resource "google_monitoring_alert_policy" "this" {
  display_name          = var.name
  combiner              = var.combiner
  notification_channels = var.notification_channels

  alert_strategy {
    auto_close = var.auto_close
  }

  dynamic "conditions" {
    for_each = var.conditions

    content {
      display_name = conditions.value.display_name

      condition_threshold {
        filter          = <<EOT
${var.resource_type != null ? "resource.type=\"${var.resource_type}\"\nAND " : ""}
metric.type="logging.googleapis.com/user/${google_logging_metric.this.name}"
EOT
        comparison      = conditions.value.comparison
        threshold_value = conditions.value.threshold_value
        duration        = conditions.value.duration
      }
    }
  }
}
