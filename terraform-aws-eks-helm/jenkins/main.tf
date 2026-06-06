resource "helm_release" "jenkins" {
  name             = var.name
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = var.chart_version
  create_namespace = false
  namespace        = var.namespace
  force_update     = false

  values = [local.manifest]

  depends_on = [kubernetes_persistent_volume.jenkins_home]

  lifecycle {
    ignore_changes = [
      timeout
    ]
  }
}

locals {
  manifest = <<YAML
controller:
  %{if var.enable_fargate_scheduling}
  nodeSelector:
    %{for key, value in var.node_selector}
    ${key}: ${value}
    %{endfor}
  tolerations:
    %{for tol in var.tolerations}
    - key:      "${tol.key}"
      operator: "${tol.operator}"
      value:    "${tol.value}"
      effect:   "${tol.effect}"
    %{endfor}
  %{endif}
  resources:
    requests:
      cpu: "${var.jenkins_cpu}"
      memory: "${var.jenkins_memory}"
    limits:
      cpu: "${var.jenkins_cpu}"
      memory: "${var.jenkins_memory}"
  probes:
    startupProbe:
      failureThreshold: 30
  jenkinsUrl: "https://${local.jenkins_fqdn}"
  jenkinsUrlProtocol: "https"
  jenkinsAdminEmail: ${var.admin_alias} <admin@c0x12c.com>
  installPlugins:
    %{for plugin in var.install_plugins}
    - ${plugin}
    %{endfor}
  additionalPlugins:
    %{for plugin in var.additional_plugins}
    - ${plugin}
    %{endfor}
  projectNamingStrategy: ""
  scriptApproval: []
  JCasC:
    defaultConfig: true
    configScripts:
      credentials: |-
        credentials:
          system:
            domainCredentials:
              - credentials:
                  - gitHubApp:
                     appID: "$${GITHUB_APP_ID}"
                     description: "GitHub app"
                     privateKey: "$${GITHUB_APP_KEY}"
                     id: "${var.github_app_credential_id}"
                     scope: GLOBAL
                  - idTokenFile:
                      audience: "sts.amazonaws.com"
                      description: "aws-web-identity-token-file"
                      id: "aws-web-identity-token-file"
                      scope: GLOBAL
                  %{if var.enabled_slack_notification}
                  - string:
                      id: "slack-bot-token"
                      scope: GLOBAL
                      secret: "${sensitive(var.slack_bot_token)}"
                  %{endif}
                  %{for config in local.general_secret_configs}
                  - string:
                      id: "${config.secret_key}"
                      secret: "${sensitive(config.secret_value)}"
                      scope: GLOBAL
                  %{endfor}
      general: |-
        jenkins:
          noUsageStatistics: true
          quietPeriod: 10
        unclassified:
          buildDiscarders:
            configuredBuildDiscarders:
              - "jobBuildDiscarder"
          timestamper:
            systemTimeFormat: "'<b>'HH:mm:ss'</b> '"
            elapsedTimeFormat: "'<b>'HH:mm:ss.S'</b> '"
            allPipelines: false
      git: |-
        security:
          gitHostKeyVerificationConfiguration:
            sshHostKeyVerificationStrategy: "acceptFirstConnectionStrategy"
      global-libraries: |-
        unclassified:
          globalLibraries:
            libraries:
              - name: "${var.shared_lib_name}"
                defaultVersion: "master"
                allowVersionOverride: "true"
                includeInChangesets: false
                retriever:
                  modernSCM:
                    scm:
                      git:
                        remote: "https://github.com/${var.github_org}/${var.jenkins_shared_lib_repo}.git"
                        credentialsId: "${var.github_app_credential_id}"
                        traits:
                          - "gitBranchDiscovery"
      script-approval: |-
        security:
          scriptApproval:
            approvedSignatures:
              - "staticMethod org.codehaus.groovy.runtime.EncodingGroovyMethods encodeBase64 byte[]"
      job-dsl: |-
        security:
          globalJobDslSecurityConfiguration:
            useScriptSecurity: false
      %{if var.enabled_dark_them}
      theme-manager: |-
        unclassified:
          themeManager:
            disableUserThemes: false
            theme: "dark"
      %{endif}
      %{if var.enabled_slack_notification}
      slack-notification: |-
        unclassified:
          slackNotifier:
            botUser: true
            sendAsText: false
            tokenCredentialId: "slack-bot-token"
      %{endif}
      github-server: |-
        unclassified:
          gitHubConfiguration:
            apiRateLimitChecker: ThrottleForNormalize
          gitHubPluginConfig:
            configs:
            - credentialsId: "${var.github_app_credential_id}"
              manageHooks: false
              name: "${var.github_org_display_name}"
            hookUrl: "https://${local.jenkins_fqdn}/github-webhook/"
      nodejs: |-
        tool:
          nodejs:
            installations:
            - name: "${var.nodejs_configuration.name}"
              properties:
              - installSource:
                  installers:
                  - nodeJSInstaller:
                      id: "${var.nodejs_configuration.version}"
                      npmPackages: "yarn"
                      npmPackagesRefreshHours: 72
      role-strategy: |-
        jenkins:
          %{if var.enabled_google_login}
          projectNamingStrategy:
            roleBased:
              forceExistingJobs: false
          authorizationStrategy:
            roleBased:
              roles:
                global:
                  - entries:
                      %{for user in local.admin_user_list}
                      - user: "${user}"
                      %{endfor}
                    name: "admin"
                    pattern: ".*"
                    permissions:
                      - "Overall/Administer"
                  - entries:
                      %{for user in local.executor_user_list}
                      - user: "${user}"
                      %{endfor}
                    name: "executor"
                    pattern: ".*"
                    permissions:
                      - "Job/Cancel"
                      - "Overall/Read"
                      - "Job/Build"
                      - "Job/Discover"
                      - "Job/Read"
                      - "View/Read"
                      - "Run/Replay"
                  - entries:
                      %{for user in local.viewer_user_list}
                      - user: "${user}"
                      %{endfor}
                    name: "viewer"
                    pattern: ".*"
                    permissions:
                      - "Overall/Read"
                      - "Job/Read"
                      - "View/Read"
          %{endif}
          %{if var.enabled_github_app_login}
          authorizationStrategy:
            projectMatrix:
              entries:
              %{for team in var.jenkins_admins}
                - group:
                    name: "${var.github_org}*${team}"
                    permissions:
                      - "Overall/Administer"
              %{endfor}
              %{for team in var.jenkins_executors}
                - group:
                    name: "${var.github_org}*${team}"
                    permissions:
                      - "Job/Cancel"
                      - "Overall/Read"
                      - "Job/Build"
                      - "Job/Discover"
                      - "Job/Read"
                      - "View/Read"
                      - "Run/Replay"
              %{endfor}
              %{for team in var.jenkins_viewer}
                - group:
                    name: "${team}"
                    permissions:
                      - "Overall/Read"
                      - "Job/Read"
                      - "View/Read"
              %{endfor}
          %{endif}
    %{if var.enabled_github_app_login}
    securityRealm: |-
      github:
        githubWebUri: "https://github.com"
        githubApiUri: "https://api.github.com"
        clientID: "${var.github_app_oauth_client_id}"
        clientSecret: "${var.github_app_oauth_client_secret}"
        oauthScopes: "read:org,user:email"
    %{endif}
    %{if var.enabled_google_login}
    securityRealm: |-
      googleOAuth2:
        clientId: "${var.google_oauth_client_id}"
        clientSecret: "${var.google_oauth_client_secret}"
    %{endif}
  %{if var.enabled_init_scripts}
  initScripts:
    - |
      import hudson.plugins.git.*
      import jenkins.model.Jenkins

      def scm = new GitSCM("https://github.com/${var.github_org}/${var.jenkins_shared_lib_repo}.git")
      scm.branches = [new BranchSpec("*/master")]
      scm.userRemoteConfigs = [new UserRemoteConfig("https://github.com/${var.github_org}/${var.jenkins_shared_lib_repo}.git", null, null, '${var.github_app_credential_id}')]

      def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "jobDsl/Jenkinsfile")

      def parent = Jenkins.instance
      def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, "seed_job")
      job.definition = flowDefinition

      parent.reload()
    %{endif}
  ingress:
    enabled: true
    ingressClassName: ${var.ingress_class_name}
    annotations:
      alb.ingress.kubernetes.io/group.name: ${var.ingress_group_name}
      kubernetes.io/ingress.class: ${var.ingress_class_name}
      alb.ingress.kubernetes.io/target-type: "ip"
      alb.ingress.kubernetes.io/healthcheck-path: "/api/health/"
      alb.ingress.kubernetes.io/scheme:  "internet-facing"
      alb.ingress.kubernetes.io/listen-ports: "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
    hostName: ${local.jenkins_fqdn}
  prometheus:
    enabled: false
  testEnabled: false
  %{if var.enabled_datadog}
  podAnnotations:
    ad.datadoghq.com/jenkins.check_names: '["jenkins"]'
    ad.datadoghq.com/jenkins.init_configs: '[{}]'
    ad.datadoghq.com/jenkins.instances: |
      [
        {
          "host": "%%host%%",
          "port": "8080"
        }
      ]
  %{endif}
  %{if var.jenkins_env_var != null || var.jenkins_config_map_name != null}
  containerEnvFrom:
    %{if var.jenkins_config_map_name != null}
    - configMapRef:
        name: ${var.jenkins_config_map_name}
    %{endif}

    %{if var.jenkins_env_var != null}
    - secretRef:
        name: ${var.jenkins_env_var}
    %{endif}
  %{endif}
  containerEnv:
    - name: DD_ENV
      value: ${var.environment}
    - name: DD_SERVICE
      value: jenkins
  %{if var.enabled_datadog}
  sidecars:
    additionalSidecarContainers:
    - name: datadog-agent
      image: datadog/agent
      ports:
        - name: dogstatsdport
          containerPort: 8125
          protocol: UDP
        - name: traceport
          containerPort: 8126
          protocol: TCP
      resources:
        requests:
          cpu: 50m
          memory: 0.25Gi
        limits:
          cpu: 50m
          memory: 0.25Gi
      envFrom:
        - secretRef:
            name: jenkins-env-var
      env:
        - name: DD_KUBERNETES_KUBELET_NODENAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: spec.nodeName
      securityContext:
        runAsUser: 0
        allowPrivilegeEscalation: false
  podSecurityContextOverride:
    runAsUser: 1000
    fsGroup: 1000
  %{endif}
persistence:
  enabled: true
  existingClaim: jenkins-home-pvc
agent:
  %{if var.enable_fargate_scheduling}
  nodeSelector:
    %{for key, value in var.node_selector}
    ${key}: ${value}
    %{endfor}
  tolerations:
    %{for tol in var.tolerations}
    - key:      "${tol.key}"
      operator: "${tol.operator}"
      value:    "${tol.value}"
      effect:   "${tol.effect}"
    %{endfor}
  %{endif}
  runAsUser: jenkins
  runAsGroup: jenkins
  showRawYaml: false
  workspaceVolume:
    type: EmptyDir
    memory: false
  containerCap: ""
  idleMinutes: 2
  connectTimeout: 600
  disableDefaultAgent: true
  podTemplates:
    tester: |
      - name: tester
        label: tester
        namespace: jenkins
        podRetention: "never"
        containers:
          - name: jnlp
            image: ${var.jenkins_base_agent_image_repo}/${var.jenkins_base_agent_image_name}:${var.jenkins_base_agent_image_tag}
            args: "^$${computer.jnlpmac} ^$${computer.name}"
            command: ""
            envVars:
              - envVar:
                  key: "JENKINS_URL"
                  value: "http://jenkins.jenkins.svc.cluster.local:8080/"
              - envVar:
                  key: "REDIS_HOSTS"
                  value: "localhost:6379,localhost:6380,localhost:6381,localhost:6382,localhost:6383,localhost:6384"
            resourceRequestCpu: 2
            resourceRequestMemory: "8Gi"
            resourceLimitCpu: 2
            resourceLimitMemory: "8Gi"
            resourceLimitEphemeralStorage: "3Gi"
            resourceRequestEphemeralStorage: "3Gi"
    heavy: |
      - name: heavy
        label: heavy
        namespace: jenkins
        podRetention: "never"
        containers:
          - name: jnlp
            image: ${var.jenkins_base_agent_image_repo}/${var.jenkins_base_agent_image_name}:${var.jenkins_base_agent_image_tag}
            args: "^$${computer.jnlpmac} ^$${computer.name}"
            command: ""
            envVars:
              - envVar:
                  key: "JENKINS_URL"
                  value: "http://jenkins.jenkins.svc.cluster.local:8080/"
              - envVar:
                  key: "REDIS_HOSTS"
                  value: "localhost:6379,localhost:6380,localhost:6381,localhost:6382,localhost:6383,localhost:6384"
            resourceRequestCpu: 8
            resourceRequestMemory: "16Gi"
            resourceLimitCpu: 8
            resourceLimitMemory: "16Gi"
            resourceLimitEphemeralStorage: "6Gi"
            resourceRequestEphemeralStorage: "6Gi"
    builder: |
      - name: builder
        label: builder
        namespace: jenkins
        nodeUsageMode: "NORMAL"
        podRetention: "never"
        idleMinutes: 5
        idleMinutesStr: "5"
        containers:
          - name: jnlp
            image: ${var.jenkins_base_agent_image_repo}/${var.jenkins_base_agent_image_name}:${var.jenkins_base_agent_image_tag}
            args: "^$${computer.jnlpmac} ^$${computer.name}"
            command: ""
            envVars:
              - envVar:
                  key: "JENKINS_URL"
                  value: "http://jenkins.jenkins.svc.cluster.local:8080/"
              - envVar:
                  key: "REDIS_HOSTS"
                  value: "localhost:6379,localhost:6380,localhost:6381,localhost:6382,localhost:6383,localhost:6384"
            resourceRequestCpu: "4"
            resourceRequestMemory: "8Gi"
            resourceLimitCpu: "4"
            resourceLimitMemory: "8Gi"
            resourceLimitEphemeralStorage: "3Gi"
            resourceRequestEphemeralStorage: "3Gi"
    lightweight: |
      - name: lightweight
        label: lightweight
        namespace: jenkins
        podRetention: "never"
        idleMinutes: 5
        idleMinutesStr: "5"
        containers:
          - name: jnlp
            image: ${var.jenkins_base_agent_image_repo}/${var.jenkins_base_agent_image_name}:${var.jenkins_base_agent_image_tag}
            args: "^$${computer.jnlpmac} ^$${computer.name}"
            command: ""
            envVars:
              - envVar:
                  key: "JENKINS_URL"
                  value: "http://jenkins.jenkins.svc.cluster.local:8080/"
              - envVar:
                  key: "REDIS_HOSTS"
                  value: "localhost:6379,localhost:6380,localhost:6381,localhost:6382,localhost:6383,localhost:6384"
            resourceRequestCpu: 1
            resourceRequestMemory: "2Gi"
            resourceLimitCpu: 1
            resourceLimitMemory: "2Gi"
            resourceLimitEphemeralStorage: "3Gi"
            resourceRequestEphemeralStorage: "3Gi"
serviceAccountAgent:
  create: false
  name: default
serviceAccount:
  create: false
  name: default
YAML
}
