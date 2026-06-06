/**
`aws_identitystore_user` is used to manage users within the AWS Identity Store,
where user information is stored and managed for Single Sign-On purposes.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user
 */
resource "aws_identitystore_user" "this" {
  display_name      = "${var.first_name} ${var.last_name}"
  identity_store_id = var.identity_store_id
  user_name         = var.user_name

  name {
    given_name  = var.first_name
    family_name = var.last_name
    formatted   = "${var.first_name} ${var.last_name}"
  }

  emails {
    value   = var.email
    primary = true
  }
}
