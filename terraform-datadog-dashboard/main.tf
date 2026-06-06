locals {
  dashboard = {
    title              = var.title
    description        = var.description
    template_variables = var.template_variables
    layout_type        = var.layout_type
    notify_list        = var.notify_list
    widgets            = var.widgets
    tags               = var.tags
  }
}

resource "datadog_dashboard_json" "this" {
  dashboard = var.layout_type == "ordered" ? jsonencode(merge(local.dashboard, {
    reflow_type = var.reflow_type
  })) : jsonencode(local.dashboard)
}
