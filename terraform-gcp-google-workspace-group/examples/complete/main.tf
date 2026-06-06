module "google_workspace_group" {
  source = "../.."

  identifier  = "example_project_developers"
  domain      = "example.com"
  name        = "Example Project Developers"
  description = "Team Example Project Developers"
  members = [
    "member_1",
    "member_2"
  ]
}
