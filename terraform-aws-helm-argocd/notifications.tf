locals {
  notification_trigger_names = [
    "on-sync-status-unknown",
    "on-deployed",
    "on-sync-failed",
    "on-sync-running",
    "on-sync-succeeded",
  ]

  notification_template_keys = {
    app_deployed            = "template.app-deployed"
    app_health_degraded     = "template.app-health-degraded"
    app_sync_failed         = "template.app-sync-failed"
    app_sync_running        = "template.app-sync-running"
    app_sync_status_unknown = "template.app-sync-status-unknown"
    app_sync_succeeded      = "template.app-sync-succeeded"
    app_out_of_sync         = "template.app-out-of-sync"
  }

  notification_templates_config = var.slack_webhook_url != "" ? {
    for key, template_key in local.notification_template_keys : template_key => yamlencode({
      webhook = {
        slack = {
          method = "POST"
          body   = format("{\"attachments\": %s}", local.notification_templates[key])
        }
      }
    })
    } : {
    for key, template_key in local.notification_template_keys : template_key => yamlencode({
      slack = {
        attachments = local.notification_templates[key]
      }
    })
  }

  notification_triggers = {
    "trigger.on-deployed" = yamlencode([
      {
        description = "Application is synced and healthy. Triggered once per commit."
        oncePer     = "app.status.operationState.syncResult.revision"
        send        = ["app-deployed"]
        when        = "app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'"
      }
    ])
    "trigger.on-health-degraded" = yamlencode([
      {
        description = "Application has degraded"
        send        = ["app-health-degraded"]
        when        = "app.status.health.status == 'Degraded'"
      }
    ])
    "trigger.on-sync-failed" = yamlencode([
      {
        description = "Application syncing has failed"
        send        = ["app-sync-failed"]
        when        = "app.status.operationState.phase in ['Error', 'Failed']"
      }
    ])
    "trigger.on-sync-running" = yamlencode([
      {
        description = "Application is being synced"
        send        = ["app-sync-running"]
        when        = "app.status.operationState.phase in ['Running']"
      }
    ])
    "trigger.on-sync-status-unknown" = yamlencode([
      {
        description = "Application status is 'Unknown'"
        send        = ["app-sync-status-unknown"]
        when        = "app.status.sync.status == 'Unknown'"
      }
    ])
    "trigger.on-sync-succeeded" = yamlencode([
      {
        description = "Application syncing has succeeded"
        send        = ["app-sync-succeeded"]
        when        = "app.status.operationState.phase in ['Succeeded']"
      }
    ])
    "trigger.on-out-of-sync" = yamlencode([
      {
        description = "Application is out of sync or has a sync error"
        send        = ["app-out-of-sync"]
        when        = "app.status.sync.status == 'OutOfSync'"
      }
    ])
  }

  notifications_values = merge(
    {
      enabled   = true
      templates = local.notification_templates_config
      triggers  = local.notification_triggers
    },
    var.slack_webhook_url != "" ? {
      secret = {
        items = {
          "slack-webhook-url" = var.slack_webhook_url
        }
      }
      notifiers = {
        "service.webhook.slack" = yamlencode({
          url = "$slack-webhook-url"
          headers = [
            {
              name  = "Content-Type"
              value = "application/json"
            }
          ]
        })
      }
      } : {
      secret = {
        items = {
          "slack-token" = var.slack_token != "" ? var.slack_token : null
        }
      }
      notifiers = {
        "service.slack" = yamlencode({
          token = "$slack-token"
        })
      }
    },
    var.slack_webhook_url != "" ? (
      var.enable_default_subscription ? {
        subscriptions = [
          {
            # The service NAME from `service.webhook.slack`, not the type. ArgoCD keys its
            # notifier registry by that name, so a recipient of "webhook:slack" is looked up as
            # a service called "webhook" and fails with "notification service is not supported".
            recipients = ["slack"]
            triggers   = local.notification_trigger_names
          }
        ]
      } : {}
      ) : (
      var.enable_default_subscription && var.default_notification_channel != "" ? {
        subscriptions = [
          {
            recipients = ["slack:${var.default_notification_channel}"]
            triggers   = local.notification_trigger_names
          }
        ]
      } : {}
    )
  )
}
