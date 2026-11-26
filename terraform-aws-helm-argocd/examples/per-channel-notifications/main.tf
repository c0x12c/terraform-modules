# One ArgoCD instance managing two environments, each reporting to its own Slack channel.
#
# The default subscription has no selector, so it would post every Application to one channel.
# notification_subscriptions replaces it with one subscription per channel, each limited by a
# label selector on the Application. Label the Applications to match:
#
#   metadata:
#     labels:
#       environment: dev

variable "slack_token" {
  description = "Slack bot token. Keep it out of source - pass it from a secret store."
  type        = string
  sensitive   = true
}

module "argocd" {
  source = "../../"

  domain_name = "example.com"
  slack_token = var.slack_token

  notification_subscriptions = [
    {
      channel  = "eng-cicd-notification-dev"
      selector = "environment=dev"
    },
    {
      # environment!=dev also matches an Application with no environment label, so an
      # unlabelled Application keeps reporting to the main channel instead of going silent.
      channel  = "eng-cicd-notification"
      selector = "environment!=dev"
      # Overrides subscription_triggers for this channel only.
      triggers = ["on-sync-status-unknown", "on-sync-failed"]
    },
  ]

  github_app = {
    secret_name     = "argocd"
    app_id          = 123456
    installation_id = 654321
    private_key     = "key"
    organization    = "example-org"
  }

  oidc_github_organization  = "example-org"
  oidc_github_client_id     = 111111
  oidc_github_client_secret = "secret"
}
