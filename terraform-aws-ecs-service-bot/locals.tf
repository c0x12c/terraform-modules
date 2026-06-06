locals {
  container_environment = concat([
    {
      name  = "MICRONAUT_ENVIRONMENTS"
      value = var.environment
    },
    {
      name  = "HTTP_CLIENT_LOG_LEVEL"
      value = var.http_client_log_level
    },
    {
      name  = "APP_DOMAIN"
      value = var.app_domain
    },
    {
      name  = "SLACK_BOT_USER_ID"
      value = var.slack_bot_user_id
    },
    {
      name  = "ALLOWED_SLACK_CHANNEL"
      value = var.allowed_slack_channel
    },
    {
      name  = "ON_CALL_SLACK_CHANNEL"
      value = var.on_call_slack_channel
    },
    {
      name  = "SLACK_USER_GROUP_NAMES"
      value = var.slack_user_group_names
    },
    {
      name  = "SLACK_CHANNEL_PREFIX"
      value = var.slack_channel_prefix
    },
    {
      name  = "GITHUB_ORG"
      value = var.github_org
    },
    {
      name  = "GITHUB_REPO_LIST"
      value = join(",", concat(var.app_repo_list, var.infra_repo_list))
    },
    {
      name  = "APP_REPO_LIST"
      value = join(",", var.app_repo_list)
    },
    {
      name  = "INFRA_REPO_LIST"
      value = join(",", var.infra_repo_list)
    },
    {
      name  = "ATLASSIAN_HOST"
      value = var.atlassian_host
    },
    {
      name  = "JENKINS_USERNAME"
      value = var.jenkins_username
    },
    {
      name  = "JENKINS_HOST"
      value = var.jenkins_host
    },
    {
      name  = "JENKINS_REPOSITORY"
      value = var.jenkins_repository
    },
    {
      name  = "ATLASSIAN_USERNAME"
      value = var.atlassian_username
    },
    {
      name  = "ATLASSIAN_PAGE_PATH_PREFIX"
      value = var.atlassian_page_path_prefix
    },
    {
      name  = "SPACE_ID"
      value = var.space_id
    },
    {
      name  = "ON_CALL_PAGE_ID"
      value = var.on_call_page_id
    },
    {
      name  = "ON_CALL_TEMPLATE_PAGE_ID"
      value = var.on_call_template_page_id
    },
    {
      name  = "ON_CALL_PROCESS_PAGE_ID"
      value = var.on_call_process_page_id
    }
  ], var.additional_environment_variables)

  container_secrets = concat([
    {
      name      = "SLACK_SIGNING_SECRET"
      valueFrom = var.slack_signing_secret_arn
    },
    {
      name      = "SLACK_BOT_TOKEN"
      valueFrom = var.slack_bot_token_arn
    },
    {
      name      = "SLACK_USER_TOKEN"
      valueFrom = var.slack_user_token_arn
    },
    {
      name      = "GITHUB_APP_ID"
      valueFrom = var.github_app_id_arn
    },
    {
      name      = "GITHUB_APP_INSTALLATION_ID"
      valueFrom = var.github_app_installation_id_arn
    },
    {
      name      = "GITHUB_APP_PRIVATE_KEY"
      valueFrom = var.github_app_private_key_arn
    },
    {
      name      = "JENKINS_API_TOKEN"
      valueFrom = var.jenkins_api_token_arn
    },
    {
      name      = "ATLASSIAN_API_TOKEN"
      valueFrom = var.atlassian_api_token_arn
    }
  ], var.additional_secret_arns)
}
