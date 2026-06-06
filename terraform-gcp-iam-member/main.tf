locals {
  member_role_list = flatten([
    for group, group_data in var.user_groups : [
      for member in group_data.members : [
        for role in group_data.roles : {
          member = member
          role   = role
        }
      ]
    ]
  ])
}

/**
manage Identity and Access Management (IAM) members for a Google Cloud project. This resource assigns a specific IAM role to a member within a given project.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member
 */
resource "google_project_iam_member" "this" {
  for_each = {
    for config in local.member_role_list : "${config.member}-${config.role}" => config
  }

  project = var.project_id
  role    = each.value.role
  member  = "user:${each.value.member}"
}
