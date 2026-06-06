module "oncall_be" {
  source = "../../"

  team_id = module.datadog_team.team_id

  schedule = {
    name        = "Oncall Schedule"
    description = "Oncall schedule for Prj X"

    time_zone = "Asia/Ho_Chi_Minh"

    layer = {
      name           = "Oncall team"
      effective_date = "2025-07-07T14:00:00+07:00"
      rotation_start = "2025-07-07T14:00:00+07:00"
      interval_days  = 7 # Weekly rotation
      users          = module.datadog_team.team_members_ids
    }
  }

  escalation_policy = {
    name                       = "Oncall Escalation Policy - BE team"
    retries                    = 10 # Retry up to 10 times to notify the user in case of failure
    resolve_page_on_policy_end = false
  }

  urgency = "high"
}

# Datadog team for oncall schedule.

locals {
  team_members = [
    "a.duong@c0x12c.com",
    "b.nguyen@c0x12c.com",
    "c.tran@c0x12c.com",
  ]
}

module "datadog_team" {
  source = "c0x12c/team/datadog"

  team_name        = "Prj X oncall team"
  team_handle      = "prj-x-oncall"
  team_description = "Prj X oncall team description"

  team_members = local.team_members
}