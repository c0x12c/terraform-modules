module "google_workspace" {
  source = "../../"

  domain = "example.com"
  groups = {
    "example_project_developers" = {
      name        = "Example Project Developers"
      description = "Team Example Project Developers"
      members = [
        "member_1",
        "member_2"
      ]
    }
  }
}
