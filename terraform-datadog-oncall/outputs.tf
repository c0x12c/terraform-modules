output "schedule_id" {
  description = "The ID of the created Datadog on-call schedule"
  value       = datadog_on_call_schedule.this.id
}

output "escalation_policy_id" {
  description = "The ID of the Datadog on-call escalation policy"
  value       = datadog_on_call_escalation_policy.this.id
}

output "routing_rule_team_id" {
  description = "The ID of the Datadog on-call team routing rules"
  value       = datadog_on_call_team_routing_rules.this.id
}
