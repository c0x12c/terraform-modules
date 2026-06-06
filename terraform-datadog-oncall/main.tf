resource "datadog_on_call_schedule" "this" {
  name      = var.schedule.name
  time_zone = var.schedule.time_zone
  teams     = [var.team_id]

  layer {
    name           = var.schedule.layer.name
    effective_date = var.schedule.layer.effective_date
    rotation_start = var.schedule.layer.rotation_start

    users = var.schedule.layer.users

    interval {
      days = var.schedule.layer.interval_days
    }
  }
}

resource "datadog_on_call_escalation_policy" "this" {
  name                       = var.escalation_policy.name
  resolve_page_on_policy_end = var.escalation_policy.resolve_page_on_policy_end
  retries                    = var.escalation_policy.retries

  step {
    assignment             = null
    escalate_after_seconds = var.escalation_policy_escalate_after_seconds
    target {
      schedule = datadog_on_call_schedule.this.id
    }
  }
}

resource "datadog_on_call_team_routing_rules" "this" {
  id = var.team_id

  rule {
    escalation_policy = datadog_on_call_escalation_policy.this.id
    urgency           = var.urgency
  }
}
