locals {
  notification_templates = {
    app_deployed            = coalesce(var.notification_templates.app_deployed, local.notification_sample_templates.app_deployed)
    app_health_degraded     = coalesce(var.notification_templates.app_health_degraded, local.notification_sample_templates.app_health_degraded)
    app_sync_failed         = coalesce(var.notification_templates.app_sync_failed, local.notification_sample_templates.app_sync_failed)
    app_sync_running        = coalesce(var.notification_templates.app_sync_running, local.notification_sample_templates.app_sync_running)
    app_sync_status_unknown = coalesce(var.notification_templates.app_sync_status_unknown, local.notification_sample_templates.app_sync_status_unknown)
    app_sync_succeeded      = coalesce(var.notification_templates.app_sync_succeeded, local.notification_sample_templates.app_sync_succeeded)
    app_out_of_sync         = coalesce(var.notification_templates.app_out_of_sync, local.notification_sample_templates.app_out_of_sync)
  }

  notification_sample_templates = {
    app_deployed            = <<EOT
[{
  "title": ":rocket: Application Deployed: {{ .app.metadata.name}}",
  "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
  "color": "#18be52",
  "fields": [
    {
      "title": "Sync Status",
      "value": "{{.app.status.sync.status}}",
      "short": true
    },
    {
      "title": "Repository",
      "value": "<{{.app.spec.source.repoURL}}|View Repo>",
      "short": true
    },
    {
      "title": "Revision",
      "value": "{{.app.status.sync.revision}}",
      "short": true
    }
    {{range $index, $c := .app.status.conditions}}
    {{if not $index}},{{end}}
    {{if $index}},{{end}}
    {
      "title": "{{$c.type}}",
      "value": "{{$c.message}}",
      "short": true
    }
    {{end}}
  ]
}]
EOT
    app_health_degraded     = <<EOT
[{
  "title": ":warning: Health Degraded: {{ .app.metadata.name}}",
  "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
  "color": "#f4c030",
  "fields": [
    {
      "title": "Sync Status",
      "value": "{{.app.status.sync.status}}",
      "short": true
    },
    {
      "title": "Repository",
      "value": "<{{.app.spec.source.repoURL}}|View Repo>",
      "short": true
    }
    {{range $index, $c := .app.status.conditions}}
    {{if not $index}},{{end}}
    {{if $index}},{{end}}
    {
      "title": ":warning: {{$c.type}}",
      "value": "{{$c.message}}",
      "short": true
    }
    {{end}}
  ]
}]
EOT
    app_sync_failed         = <<EOT
[{
  "title": ":x: Sync Failed: {{ .app.metadata.name}}",
  "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
  "color": "#E96D76",
  "fields": [
    {
      "title": "Sync Status",
      "value": "{{.app.status.sync.status}}",
      "short": true
    },
    {
      "title": "Repository",
      "value": "<{{.app.spec.source.repoURL}}|View Repo>",
      "short": true
    }
    {{range $index, $c := .app.status.conditions}}
    {{if not $index}},{{end}}
    {{if $index}},{{end}}
    {
      "title": ":x: {{$c.type}}",
      "value": "{{$c.message}}",
      "short": true
    }
    {{end}}
  ]
}]
EOT
    app_sync_running        = <<EOT
[{
  "title": ":hourglass_flowing_sand: Sync In Progress: {{ .app.metadata.name}}",
  "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
  "color": "#0DADEA",
  "fields": [
    {
      "title": "Sync Status",
      "value": "{{.app.status.sync.status}}",
      "short": true
    },
    {
      "title": " Repository",
      "value": "<{{.app.spec.source.repoURL}}|View Repo>",
      "short": true
    }
    {{range $index, $c := .app.status.conditions}}
    {{if not $index}},{{end}}
    {{if $index}},{{end}}
    {
      "title": "{{$c.type}}",
      "value": "{{$c.message}}",
      "short": true
    }
    {{end}}
  ]
}]
EOT
    app_sync_status_unknown = <<EOT
[{
  "title": ":question: Sync Status Unknown: {{ .app.metadata.name}}",
  "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
  "color": "#E96D76",
  "fields": [
    {
      "title": "Sync Status",
      "value": "{{.app.status.sync.status}}",
      "short": true
    },
    {
      "title": "Repository",
      "value": "<{{.app.spec.source.repoURL}}|View Repo>",
      "short": true
    }
    {{range $index, $c := .app.status.conditions}}
    {{if not $index}},{{end}}
    {{if $index}},{{end}}
    {
      "title": ":question: {{$c.type}}",
      "value": "{{$c.message}}",
      "short": true
    }
    {{end}}
  ]
}]
EOT
    app_sync_succeeded      = <<EOT
[{
  "title": ":white_check_mark: Sync Succeeded: {{ .app.metadata.name}}",
  "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
  "color": "#18be52",
  "fields": [
    {
      "title": "Sync Status",
      "value": "{{.app.status.sync.status}}",
      "short": true
    },
    {
      "title": "Repository",
      "value": "<{{.app.spec.source.repoURL}}|View Repo>",
      "short": true
    }
    {{range $index, $c := .app.status.conditions}}
    {{if not $index}},{{end}}
    {{if $index}},{{end}}
    {
      "title": "{{$c.type}}",
      "value": "{{$c.message}}",
      "short": true
    }
    {{end}}
  ]
}]
EOT
    app_out_of_sync         = <<EOT
[{
  "title": "Out of Sync: {{ .app.metadata.name}}",
  "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
  "color": "#f4c030",
  "fields": [
    {
      "title": " Sync Status",
      "value": "{{.app.status.sync.status}}",
      "short": true
    },
    {
      "title": "Repository",
      "value": "<{{.app.spec.source.repoURL}}|View Repo>",
      "short": true
    }
    {{range $index, $c := .app.status.conditions}}
    {{if not $index}},{{end}}
    {{if $index}},{{end}}
    {
      "title": "{{$c.type}}",
      "value": "{{$c.message}}",
      "short": true
    }
    {{end}}
  ],
  "footer": "ArgoCD Sync Issue"
}]

EOT
  }

  node_selectors = flatten([
    for key, value in var.node_selector : {
      key   = key
      value = value
    }
  ])

  in_clusters = compact(distinct([
    "in-cluster",
    var.enabled_managed_in_cluster == true ? var.in_cluster_name : null
  ]))

  # ----- MANIFEST YAML FILE ------
  manifest = <<YAML
global:
  domain: "${var.sub_domain}.${var.domain_name}"
  %{if length(local.node_selectors) > 0}
  nodeSelector:
    %{for node in local.node_selectors}
    ${node.key}: ${node.value}
    %{endfor}
  %{endif}
  %{if length(var.tolerations) > 0}
  tolerations:
    %{for toleration in var.tolerations}
    - key: ${toleration.key}
      operator: ${toleration.operator}
      value: ${toleration.value}
      effect: ${toleration.effect}
    %{endfor}
  %{endif}
server:
  ingress:
    enabled: true
    hostname: "${var.sub_domain}.${var.domain_name}"
    ingressClassName: ${var.ingress_class_name}
    controller: aws
    annotations:
      alb.ingress.kubernetes.io/group.name: ${var.ingress_group_name}
      kubernetes.io/ingress.class: ${var.ingress_class_name}
      alb.ingress.kubernetes.io/target-type: "ip"
      alb.ingress.kubernetes.io/scheme: ${var.ingress_scheme}
      alb.ingress.kubernetes.io/listen-ports: "[{\"HTTPS\": 443}]"
    path: /
    pathType: Prefix

dex:
  enabled: true

configs:
  params:
    server.insecure: ${!var.handle_tls}
    controller.diff.server.side: "${var.server_side_diff}"
  cm:
    dex.config: |
      connectors:
        - type: github
          id: github
          name: GitHub
          config:
            clientID: ${var.oidc_github_client_id}
            clientSecret: ${var.oidc_github_client_secret}
            orgs:
              - name: ${var.oidc_github_organization}
        %{for key, creds in var.external_github_oauth_creds}
        - type: github
          id: github-${key}
          name: Github ${key}
          config:
            clientID: ${creds.client_id}
            clientSecret: $github-oauth-${key}:dex.${key}.clientSecret
            orgs:
              - name: ${key}
        %{endfor}
      issuer: ${var.issuer_url}
  rbac:
    policy.csv: |
      ${join("\n", var.rbac_policies)}
  clusterCredentials:
    %{for cluster in local.in_clusters}
    ${cluster}:
      server: https://kubernetes.default.svc
      annotations: {}
      labels: {}
      clusterResources: false
      config:
        tlsClientConfig:
          insecure: false
    %{endfor}
    %{for key, cluster in var.external_clusters}
    ${key}:
      server: ${cluster.server}
      %{if length(cluster.annotations) > 0}
      annotations:
      %{for annotation_key, annotation_value in cluster.annotations}
        ${annotation_key}: ${annotation_value}
      %{endfor}
      %{endif}
      %{if length(cluster.labels) > 0}
      labels:
      %{for label_key, label_value in cluster.labels}
        ${label_key}: ${label_value}
      %{endfor}
      %{endif}
      %{if cluster.cluster_resources}
      clusterResources: ${cluster.cluster_resources}
      namespace: ${cluster.namespace}
      %{endif}
      config:
        awsAuthConfig:
          clusterName: ${cluster.config.aws_auth_config.cluster_name}
          roleARN: ${cluster.config.aws_auth_config.role_arn}
        tlsClientConfig:
          insecure: ${cluster.config.tls_client_config.insecure}
          caData: ${cluster.config.tls_client_config.ca_data}
    %{endfor}
notifications:
  enabled: true
  secret:
    items:
      slack-token: ${var.slack_token}
  %{if var.default_notification_channel != ""}
  subscriptions:
    - recipients:
        - slack:${var.default_notification_channel}
      triggers:
        - on-sync-status-unknown
        - on-deployed
        - on-sync-failed
        - on-sync-running
        - on-sync-succeeded
  %{endif}
  notifiers:
    service.slack: |
      token: $slack-token
  templates:
    template.app-deployed: |
      slack:
        attachments: |-
          ${indent(10, local.notification_templates.app_deployed)}
    template.app-health-degraded: |
      slack:
        attachments: |-
          ${indent(10, local.notification_templates.app_health_degraded)}
    template.app-sync-failed: |
      slack:
        attachments: |-
          ${indent(10, local.notification_templates.app_sync_failed)}
    template.app-sync-running: |
      slack:
        attachments: |-
          ${indent(10, local.notification_templates.app_sync_running)}
    template.app-sync-status-unknown: |
      slack:
        attachments: |-
          ${indent(10, local.notification_templates.app_sync_status_unknown)}
    template.app-sync-succeeded: |
      slack:
        attachments: |-
          ${indent(10, local.notification_templates.app_sync_succeeded)}
    template.app-out-of-sync: |
      slack:
        attachments: |-
          ${indent(10, local.notification_templates.app_out_of_sync)}
  triggers:
    trigger.on-deployed: |
      - description: Application is synced and healthy. Triggered once per commit.
        oncePer: app.status.sync.revision
        send:
        - app-deployed
        when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
        oncePer: app.status.operationState.syncResult.revision
    trigger.on-health-degraded: |
      - description: Application has degraded
        send:
        - app-health-degraded
        when: app.status.health.status == 'Degraded'
    trigger.on-sync-failed: |
      - description: Application syncing has failed
        send:
        - app-sync-failed
        when: app.status.operationState.phase in ['Error', 'Failed']
    trigger.on-sync-running: |
      - description: Application is being synced
        send:
        - app-sync-running
        when: app.status.operationState.phase in ['Running']
    trigger.on-sync-status-unknown: |
      - description: Application status is 'Unknown'
        send:
        - app-sync-status-unknown
        when: app.status.sync.status == 'Unknown'
    trigger.on-sync-succeeded: |
      - description: Application syncing has succeeded
        send:
        - app-sync-succeeded
        when: app.status.operationState.phase in ['Succeeded']
    trigger.on-out-of-sync: |
      - description: Application is out of sync or has a sync error
        send:
        - app-out-of-sync
        when: app.status.sync.status == 'OutOfSync'
YAML
}
