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
  domain_name                  = "example.invalid"
  oidc_github_client_id        = "fake-client-id"
  oidc_github_client_secret    = "fake-client-secret"
  oidc_github_organization     = "fake-organization"
  create_github_app_secret     = false
  slack_token                  = "fake-token"
  default_notification_channel = "eng-cicd-notification"
}

run "default_subscription_unchanged" {
  command = plan

  assert {
    condition = nonsensitive(yamldecode(helm_release.this.values[0]).notifications.subscriptions) == [
      {
        recipients = ["slack:eng-cicd-notification"]
        triggers   = ["on-sync-status-unknown", "on-deployed", "on-sync-failed", "on-sync-running", "on-sync-succeeded"]
      }
    ]
    error_message = "Without notification_subscriptions the single default subscription must render as before."
  }
}

run "per_channel_subscriptions_replace_default" {
  command = plan

  variables {
    notification_subscriptions = [
      { channel = "eng-cicd-notification-dev", selector = "environment=dev", triggers = ["on-sync-status-unknown"] },
      { channel = "eng-cicd-notification", selector = "environment!=dev" },
    ]
  }

  assert {
    condition = nonsensitive(yamldecode(helm_release.this.values[0]).notifications.subscriptions) == [
      {
        recipients = ["slack:eng-cicd-notification-dev"]
        selector   = "environment=dev"
        triggers   = ["on-sync-status-unknown"]
      },
      {
        recipients = ["slack:eng-cicd-notification"]
        selector   = "environment!=dev"
        triggers   = ["on-sync-status-unknown", "on-deployed", "on-sync-failed", "on-sync-running", "on-sync-succeeded"]
      },
    ]
    error_message = "notification_subscriptions must replace the default subscription, keep each selector, and fall back to subscription_triggers."
  }
}

run "rejects_unknown_trigger" {
  command = plan

  variables {
    notification_subscriptions = [
      { channel = "eng-cicd-notification", triggers = ["app-deployed"] },
    ]
  }

  expect_failures = [var.notification_subscriptions]
}

run "rejects_empty_channel" {
  command = plan

  variables {
    notification_subscriptions = [
      { channel = " " },
    ]
  }

  expect_failures = [var.notification_subscriptions]
}

run "rejects_webhook_path" {
  command = plan

  variables {
    slack_token       = ""
    slack_webhook_url = "https://example.invalid/hook"
    notification_subscriptions = [
      { channel = "eng-cicd-notification" },
    ]
  }

  expect_failures = [var.notification_subscriptions]
}
