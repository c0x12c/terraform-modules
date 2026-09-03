# Narrowing which triggers the module-wide subscription sends.
#
# The default is the five sync-lifecycle triggers, which produces five Slack messages for one
# successful deploy: three progress notices plus both "Application Deployed" and "Sync Succeeded"
# for the same outcome.

variable "slack_webhook_url" {
  description = "Slack incoming webhook URL. Keep it out of source - pass it from a secret store."
  type        = string
  sensitive   = true
}

module "argocd" {
  source = "../../"

  domain_name       = "example.com"
  slack_webhook_url = var.slack_webhook_url

  # on-deployed also gates on Healthy and sets oncePer the sync revision, so it fires once per
  # commit. on-sync-succeeded has neither guard: it repeats the event and fires again on every
  # no-op self-heal resync. Dropped with it: on-sync-running and on-sync-status-unknown.
  subscription_triggers = [
    "on-deployed",
    "on-sync-failed",
  ]

  # Health stays covered per Application rather than fleet-wide:
  #   notifications.argoproj.io/subscribe.on-health-degraded.slack: ""

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

# An unknown name fails at plan time, because ArgoCD ignores an unrecognised trigger silently and a
# typo would otherwise just stop sending with nothing in the logs to find. on-created and
# on-deleted are defined but left out of the default - on-created carries when: "true".
