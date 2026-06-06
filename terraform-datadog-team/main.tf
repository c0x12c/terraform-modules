resource "datadog_team" "this" {
  name        = var.team_name
  handle      = var.team_handle
  description = var.team_description
}

data "datadog_user" "this" {
  for_each = toset(var.team_members)

  filter = each.value
}

resource "datadog_team_membership" "this" {
  for_each = data.datadog_user.this

  team_id = datadog_team.this.id
  user_id = each.value.id
}