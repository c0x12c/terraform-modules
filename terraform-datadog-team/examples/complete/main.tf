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