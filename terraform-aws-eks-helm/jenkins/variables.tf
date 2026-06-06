variable "chart_version" {
  description = "The Jenkins chart version"
  type        = string
  default     = "5.8.10"
}

variable "name" {
  type    = string
  default = "jenkins"
}

variable "domain" {
  description = "The root domain of project"
  type        = string
}

variable "github_org_display_name" {
  description = "The Github org display name. There should be no whitespaces within."
  type        = string
}

variable "github_app_oauth_client_id" {
  description = "The Client ID of Spartan SSO"
  type        = string
  default     = ""
}

variable "github_app_oauth_client_secret" {
  description = "The Client Secret of Spartan SSO"
  type        = string
  sensitive   = true
  default     = ""
}

variable "jenkins_admins" {
  type        = list(string)
  default     = []
  description = "List of Jenkins admins"
}


variable "jenkins_executors" {
  type        = list(string)
  default     = []
  description = "List of Jenkins executors"
}

variable "jenkins_viewer" {
  description = "List of Jenkins viewer"
  type        = list(string)
  default     = []
}

variable "jenkins_shared_lib_repo" {
  description = "The Jenkins shared library repo"
  type        = string
}

variable "namespace" {
  description = "Namespace to install Jenkins. Default is jenkins"
  type        = string
  default     = "jenkins"
}

variable "general_secrets" {
  description = "Secrets are shared across all repos"
  type        = map(string)
}

variable "jenkins_base_agent_image_repo" {
  description = "The base image for Jenkins agents"
  type        = string
}

variable "jenkins_base_agent_image_name" {
  description = "The base image for Jenkins agents"
  type        = string
}

variable "jenkins_base_agent_image_tag" {
  description = "The base image for Jenkins agents"
  type        = string
}

variable "slack_bot_token" {
  description = "The slack bot token"
  type        = string
  default     = null
}

variable "google_user_list" {
  description = "List users and roles for accessing Jenkins"
  type        = map(list(string))
  default     = null
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "github_app_credential_id" {
  description = "GitHub App credentials key for jenkins"
  type        = string
  default     = "github-credentials"
}

variable "efs_id" {
  description = "EFS is for mounting Jenkins home"
  type        = string
}

variable "efs_jenkins_access_point" {
  description = "EFS is for mounting Jenkins home"
  type        = string
  default     = "/jenkins-home"
}

variable "efs_storage_class_name" {
  description = "EFS storage class of Jenkins volume"
  type        = string
  default     = "efs"
}

variable "efs_volume_size" {
  description = "EFS volume size"
  type        = string
  default     = "30Gi"
}

variable "github_org" {
  description = "The Github org name"
  type        = string
}

variable "jenkins_dns_name" {
  description = "The Jenkins DNS name"
  type        = string
  default     = "jenkins"
}

variable "jenkins_fqdn" {
  description = "FQDN of Jenkins service"
  type        = string
  default     = ""
}

variable "ingress_class_name" {
  description = "The ingress class name of Jenkins ingress"
  type        = string
  default     = "alb"
}

variable "ingress_group_name" {
  description = "The ingress group name of Jenkins ingress"
  type        = string
  default     = "external"
}

variable "shared_lib_name" {
  description = "The name Jenkins uses to name the shared library"
  type        = string
  default     = "spartan"
}

variable "jenkins_cpu" {
  description = "The CPU request and limit for Jenkins"
  type        = string
  default     = "1950m"
}

variable "jenkins_memory" {
  description = "The memory request and limit for Jenkins"
  type        = string
  default     = "4.5Gi"
}

variable "admin_alias" {
  description = "The alias of Jenkins admin"
  type        = string
  default     = "Spartan"
}

variable "enabled_datadog" {
  description = "Enable Datadog monitoring"
  type        = bool
  default     = true
}

variable "enabled_github_app_login" {
  description = "Enable Github App login, only one of Github App login or Google login can be enabled"
  type        = bool
  default     = false
}

variable "enabled_google_login" {
  description = "Enable Google login, only one of Github App login or Google login can be enabled"
  type        = bool
  default     = false

  # References in Variable Validation is not yet supported in OpenTofu
  # We need to wait for v1.9.0 to release https://github.com/opentofu/opentofu/pull/2216
  # validation {
  #   condition     = !(var.enabled_github_app_login && var.enabled_google_login)
  #   error_message = "Only one of Github App login or Google login can be enabled"
  # }
}

variable "google_oauth_client_id" {
  description = "The Client ID of Google SSO"
  type        = string
  default     = ""
}

variable "google_oauth_client_secret" {
  description = "The Client Secret of Google SSO"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enabled_init_scripts" {
  description = "Enable init scripts"
  type        = bool
  default     = true
}

variable "enabled_slack_notification" {
  description = "Enable Slack notification"
  type        = bool
  default     = true
}

variable "install_plugins" {
  description = "List of Jenkins plugins to install"
  type        = list(string)
  default = [
    "configuration-as-code:1932.v75cb_b_f1b_698d",
    "git:5.7.0",
    "kubernetes:4306.vc91e951ea_eb_d",
    "workflow-aggregator:600.vb_57cdd26fdd7"
  ]
}

variable "additional_plugins" {
  description = "List of additional Jenkins plugins to install"
  type        = list(string)
  default = [
    "ansicolor:1.0.6",
    "blueocean:1.27.16",
    "config-file-provider:982.vb_a_e458a_37021",
    "credentials:1413.va_51c53703df1",
    "dark-theme:524.vd675b_22b_30cb_",
    "extended-read-permission:61.vf24570ff3b_e9",
    "github:1.41.0",
    "github-oauth:621.v33b_4394dda_4d",
    "google-login:109.v022b_cf87b_e5b_",
    "http_request:1.20",
    "job-dsl:1.90",
    "matrix-auth:3.2.4",
    "nodejs:1.6.3",
    "oidc-provider:89.v3dfb_6d89b_618",
    "pipeline-stage-view:2.35",
    "pipeline-utility-steps:2.18.0",
    "role-strategy:756.v978cb_392eb_d3",
    "slack:761.v2a_8770f0d169",
    "sonar:2.18",
    "sshd:3.350.v1080103a_10fd",
    "theme-manager:278.v2e3c063e42cc",
    "timestamper:1.28",
    "ws-cleanup:0.48"
  ]
}

variable "enabled_dark_them" {
  description = "Enable dark theme"
  type        = bool
  default     = false
}

variable "jenkins_env_var" {
  description = "Jenkins environment variables"
  type        = string
  default     = null
}

variable "jenkins_config_map_name" {
  description = "Jenkins config map name"
  type        = string
  default     = null
}

variable "kaniko_version" {
  description = "Version of Kaniko build tool"
  type        = string
  default     = "v1.21.1"
}

variable "nodejs_configuration" {
  description = "To custom and define NodeJS values"
  type = object({
    name    = string
    version = string
  })
  default = {
    name    = "Node 20"
    version = "20.10.0"
  }
}

variable "enable_fargate_scheduling" {
  description = "If true, Jenkins pods will be forced onto Fargate (via nodeSelector + tolerations)"
  type        = bool
  default     = false
}

variable "node_selector" {
  description = "Map of labels to force pods onto Fargate nodes"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "List of tolerations required to schedule onto Fargate nodes"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}
