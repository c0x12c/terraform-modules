/**
`googleworkspace_group` resource manages Google Workspace Groups.
Group resides under the https://www.googleapis.com/auth/admin.directory.group client scope.
https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group
 */
resource "googleworkspace_group" "this" {
  email       = "${var.identifier}@${var.domain}"
  name        = var.name
  description = var.description
}

/**
`googleworkspace_group_member` resource manages Google Workspace Groups Members.
Group Member resides under the https://www.googleapis.com/auth/admin.directory.group client scope.
https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group_member
 */
resource "googleworkspace_group_member" "this" {
  for_each = toset(var.members)

  group_id = googleworkspace_group.this.id
  email    = "${each.value}@${var.domain}"
}
