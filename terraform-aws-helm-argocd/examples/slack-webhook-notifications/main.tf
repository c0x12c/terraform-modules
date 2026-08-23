# Notifications delivered through a Slack incoming webhook instead of a bot token.
#
# Use this when you have a webhook URL but no bot token. ArgoCD's `service.slack` notifier
# authenticates with a token and has no webhook mode, so the module switches to ArgoCD's
# `service.webhook` type when `slack_webhook_url` is set. The two inputs are mutually exclusive:
# setting both fails validation, because it would deliver every event twice.

module "argocd" {
  source = "../../"

  domain_name = "example.com"

  # The webhook fixes the destination channel, so `default_notification_channel` plays no part
  # here. `enable_default_subscription` is the only switch on this path - leave it at its default
  # of true to subscribe every Application, or set it false to subscribe none and opt in per app.
  slack_webhook_url = var.slack_webhook_url

  # enable_default_subscription = false

  # The default subscription covers the five sync-lifecycle triggers. `on-health-degraded` and
  # `on-out-of-sync` are templated but deliberately left out of it, because they fire per
  # application rather than per deploy. Subscribe an individual Application to one by annotating
  # it. Both paths address the notifier by its service NAME, so both read `.slack`.
  # The webhook needs no channel - it fixes its own destination:
  #
  #   notifications.argoproj.io/subscribe.on-health-degraded.slack: ""
  #
  # against the bot-token form, which names the channel:
  #
  #   notifications.argoproj.io/subscribe.on-health-degraded.slack: "eng-cicd-notification"

  github_app = {
    secret_name     = "argocd"
    app_id          = 123456
    installation_id = 654321
    private_key     = "key"
    organization    = "spartan-stratos"
  }

  oidc_github_organization  = "spartan-stratos"
  oidc_github_client_id     = 111111
  oidc_github_client_secret = "secret"
}

variable "slack_webhook_url" {
  description = "Slack incoming webhook URL. Keep it out of source - pass it from a secret store."
  type        = string
  sensitive   = true
}
