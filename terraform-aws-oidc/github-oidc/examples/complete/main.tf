module "github_oidc" {
  source          = "../../"
  role_name       = "service-atlas"
  repository_path = "spartan/example"

  role_policy_arns = []
  conditions = [
    {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:spartan/example"]
    }
  ]
}
