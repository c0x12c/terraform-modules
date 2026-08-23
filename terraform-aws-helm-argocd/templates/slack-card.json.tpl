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
    }%{ if spec.include_revision },
    {
      "title": "Revision",
      "value": "{{.app.status.sync.revision}}",
      "short": true
    }%{ endif }
    {{range $index, $c := .app.status.conditions}}
    {{if not $index}},{{end}}
    {{if $index}},{{end}}
    {
      "title": "${spec.condition_title_prefix}{{$c.type}}",
      "value": "{{$c.message}}",
      "short": true
    }
    {{end}}
  ]%{ if spec.footer != null },
  "footer": "${spec.footer}"%{ endif }
}]
