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

run "upgrade_safe_defaults" {
  command = plan

  assert {
    condition     = helm_release.this.version == "10.19.1"
    error_message = "The default chart must be argo-cd 10.19.1 (Argo CD v3.6.3)."
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).configs.cm["application.resourceTrackingMethod"] == "label"
    error_message = "Resource tracking must stay on label by default so the upgrade does not re-apply every resource."
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).global.networkPolicy.create == false
    error_message = "Chart NetworkPolicies must stay off by default."
  }
}

run "tracking_and_network_policy_overrides" {
  command = plan

  variables {
    resource_tracking_method = "annotation"
    network_policy_enabled   = true
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).configs.cm["application.resourceTrackingMethod"] == "annotation"
    error_message = "resource_tracking_method must render into argocd-cm."
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).global.networkPolicy.create == true
    error_message = "network_policy_enabled must render into global.networkPolicy.create."
  }
}

run "rejects_unknown_tracking_method" {
  command = plan

  variables {
    resource_tracking_method = "labels"
  }

  expect_failures = [var.resource_tracking_method]
}
