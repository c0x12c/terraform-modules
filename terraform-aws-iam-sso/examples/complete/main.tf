module "iam_sso" {
  source = "../../"

  groups = {
    "Developers" = {
      users = {
        "sample.user@email.abc" = {
          first_name = "Sample"
          last_name  = "User"
          user_name  = "sample.user"
        },
      }
      aws_accounts = {
        "0123456789" = {
          "PermissionSetName1" = "arn:aws:sso:::permissionSet/permissionSetArn1"
          "PermissionSetName2" = "arn:aws:sso:::permissionSet/permissionSetArn2"
        }
      }
    }
  }
}
