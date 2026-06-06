output "team_id" {
  description = "The ID of the created Datadog team."
  value       = datadog_team.this.id
}

output "team_members_ids" {
  description = "The list of user IDs for the members of the team."
  value       = [for user in data.datadog_user.this : user.id]
}
