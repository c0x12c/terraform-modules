# The real aws provider renders the policy document; a mock would return fake json and the assertions would test nothing.
provider "aws" {
  region                      = "us-west-2"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

mock_provider "tls" {}

override_data {
  target = data.aws_caller_identity.this
  values = {
    account_id = "111122223333"
  }
}

override_module {
  target = module.provider
  outputs = {
    arn = "arn:aws:iam::111122223333:oidc-provider/token.actions.githubusercontent.com"
    url = "token.actions.githubusercontent.com"
  }
}

variables {
  role_name       = "oidc-test"
  repository_path = "example-org/example-repo"
}

run "default_keeps_account_root_trust" {
  command = plan

  assert {
    condition     = length(jsondecode(data.aws_iam_policy_document.assume_role_github.json).Statement) == 2
    error_message = "Default trust must keep both statements."
  }

  assert {
    condition     = jsondecode(data.aws_iam_policy_document.assume_role_github.json).Statement[0].Action == "sts:AssumeRole"
    error_message = "The account-root statement must stay first so existing consumers see no diff."
  }
}

run "opt_out_leaves_only_web_identity" {
  command = plan

  variables {
    trust_account_root = false
  }

  assert {
    condition     = length(jsondecode(data.aws_iam_policy_document.assume_role_github.json).Statement) == 1
    error_message = "trust_account_root = false must drop the account-root statement."
  }

  assert {
    condition     = jsondecode(data.aws_iam_policy_document.assume_role_github.json).Statement[0].Action == "sts:AssumeRoleWithWebIdentity"
    error_message = "The remaining statement must be the GitHub web-identity statement."
  }
}

run "rejects_malformed_repository_path" {
  command = plan

  variables {
    repository_path = "no-slash"
  }

  expect_failures = [var.repository_path]
}
