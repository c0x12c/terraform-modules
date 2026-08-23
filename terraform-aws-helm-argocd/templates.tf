locals {
  notification_template_specs = {
    app_deployed = {
      title                  = ":rocket: Application Deployed: {{ .app.metadata.name}}"
      color                  = "#18be52"
      repository_title       = "Repository"
      sync_status_title      = "Sync Status"
      condition_title_prefix = ""
      include_revision       = true
      footer                 = null
    }
    app_health_degraded = {
      title                  = ":warning: Health Degraded: {{ .app.metadata.name}}"
      color                  = "#f4c030"
      repository_title       = "Repository"
      sync_status_title      = "Sync Status"
      condition_title_prefix = ":warning: "
      include_revision       = false
      footer                 = null
    }
    app_sync_failed = {
      title                  = ":x: Sync Failed: {{ .app.metadata.name}}"
      color                  = "#E96D76"
      repository_title       = "Repository"
      sync_status_title      = "Sync Status"
      condition_title_prefix = ":x: "
      include_revision       = false
      footer                 = null
    }
    app_sync_running = {
      title                  = ":hourglass_flowing_sand: Sync In Progress: {{ .app.metadata.name}}"
      color                  = "#0DADEA"
      repository_title       = " Repository"
      sync_status_title      = "Sync Status"
      condition_title_prefix = ""
      include_revision       = false
      footer                 = null
    }
    app_sync_status_unknown = {
      title                  = ":question: Sync Status Unknown: {{ .app.metadata.name}}"
      color                  = "#E96D76"
      repository_title       = "Repository"
      sync_status_title      = "Sync Status"
      condition_title_prefix = ":question: "
      include_revision       = false
      footer                 = null
    }
    app_sync_succeeded = {
      title                  = ":white_check_mark: Sync Succeeded: {{ .app.metadata.name}}"
      color                  = "#18be52"
      repository_title       = "Repository"
      sync_status_title      = "Sync Status"
      condition_title_prefix = ""
      include_revision       = false
      footer                 = null
    }
    app_out_of_sync = {
      title                  = "Out of Sync: {{ .app.metadata.name}}"
      color                  = "#f4c030"
      repository_title       = "Repository"
      sync_status_title      = " Sync Status"
      condition_title_prefix = ""
      include_revision       = false
      footer                 = "ArgoCD Sync Issue"
    }
  }
}

locals {
  # One card shape drives all seven notifications; the table above carries only the deltas.
  # This stays a text template rather than jsonencode because the body is not valid JSON until
  # ArgoCD expands it - the {{range}} over conditions sits outside any string.
  notification_sample_templates = {
    for key, spec in local.notification_template_specs : key => <<-EOT
    [{
      "title": "${spec.title}",
      "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
      "color": "${spec.color}",
      "fields": [
        {
          "title": "${spec.sync_status_title}",
          "value": "{{.app.status.sync.status}}",
          "short": true
        },
        {
          "title": "${spec.repository_title}",
          "value": "<{{.app.spec.source.repoURL}}|View Repo>",
          "short": true
        }%{if spec.include_revision},
        {
          "title": "Revision",
          "value": "{{.app.status.sync.revision}}",
          "short": true
        }%{endif}
        {{range $index, $c := .app.status.conditions}}
        {{if not $index}},{{end}}
        {{if $index}},{{end}}
        {
          "title": "${spec.condition_title_prefix}{{$c.type}}",
          "value": "{{$c.message}}",
          "short": true
        }
        {{end}}
      ]%{if spec.footer != null},
      "footer": "${spec.footer}"%{endif}
    }]
    EOT
  }
}

locals {
  notification_templates = {
    for key, sample in local.notification_sample_templates :
    key => coalesce(lookup(var.notification_templates, key, null), sample)
  }
}
