mock_provider "helm" {}

mock_provider "kubernetes" {}

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:root"
      user_id    = "fake-user"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  domain_name               = "example.invalid"
  oidc_github_client_id     = "fake-client-id"
  oidc_github_client_secret = "fake-client-secret"
  oidc_github_organization  = "fake-organization"
  create_github_app_secret  = false
}

run "defaults" {
  command = plan

  assert {
    condition     = length(helm_release.this.values) == 1
    error_message = "Default values must contain only the module manifest."
  }
}

run "extra_values" {
  command = plan

  variables {
    extra_values = ["repoServer:\n  resources:\n    requests:\n      memory: 512Mi\n"]
  }

  assert {
    condition     = length(helm_release.this.values) == 2
    error_message = "Extra values must be appended to the module manifest."
  }

  assert {
    condition     = helm_release.this.values[1] == "repoServer:\n  resources:\n    requests:\n      memory: 512Mi\n"
    error_message = "The appended values document must match the caller's YAML string."
  }
}
