module "iam_member" {
  source = "../../"

  project_id = "example"
  user_groups = {
    "Dev" = {
      members = [
        "member_1@example.com",
        "member_2@example.com",
      ]
      roles = [
        "roles/editor",
        "roles/secretmanager.secretAccessor"
      ]
    }
    "Admin" = {
      members = [
        "admin@example.com",
      ]
      roles = [
        "roles/admin",
      ]
    }
  }
}
