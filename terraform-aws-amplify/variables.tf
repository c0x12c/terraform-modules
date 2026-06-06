variable "name" {
  description = "The name for the Amplify app"
  type        = string
}

variable "environment" {
  description = "Environment for the Amplify app"
  type        = string
}

variable "repository" {
  description = "Source repository for Amplify app"
  type        = string
}

variable "dns_zone" {
  description = "DNS zone for creating domain"
  type        = string
}

variable "github_token" {
  description = "Github access token for authorizing with Github"
  type        = string
}

variable "build_variables" {
  description = "Map of environment variables for building app"
  type        = map(string)
}

variable "sub_domain" {
  description = "Subdomain for the Amplify app"
  type        = string
  default     = ""
}

variable "deploy_branch_name" {
  description = "The branch name to deploy the source code"
  type        = string
}

variable "application_root" {
  description = "The root directory for building application"
  type        = string
}

variable "custom_redirect_rules" {
  description = "Custom redirect rules for redirecting requests to Amplify app"
  type = list(object({
    source = string
    status = string
    target = string
  }))
  default = [
    {
      source = "/<*>"
      status = "404"
      target = "/index.html"
    }
  ]
}

variable "web_platform" {
  description = "Amplify App platform for building web app"
  type        = string
  default     = "WEB"
}

variable "base_artifacts_directory" {
  description = "Base directory that stores build artifacts"
  type        = string
  default     = ".next"
}

variable "install_command" {
  description = "The install command to install packages"
  type        = string
  default     = "yarn install"
}

variable "build_command" {
  description = "The build command to execute JS scripts"
  type        = string
  default     = "yarn build"
}

variable "enable_backend" {
  description = "To enable aws_amplify_backend_environment"
  type        = bool
  default     = true
}

variable "framework" {
  description = "Optional framework for the branch"
  type        = string
  default     = null
}

variable "enable_redirect_to_root" {
  description = "To enable redirect to the root"
  type        = bool
  default     = false
}

# Notification
variable "slack_webhook_url" {
  description = "To define webhook url for notifying statuses to Slack"
  type        = string
  default     = null
}

variable "enabled_notification" {
  description = "To enable the webhook notification to slack, which will create resources relating lambda function and eventbridge to semd a message"
  type        = bool
  default     = false
}

variable "enable_auto_build" {
  description = "To enable auto build for deployment branch"
  type        = bool
  default     = true
}

variable "custom_headers" {
  description = "Custom HTTP headers for the Amplify app"
  type = list(object({
    pattern = string
    headers = list(object({
      key   = string
      value = string
    }))
  }))
  default = []
}
