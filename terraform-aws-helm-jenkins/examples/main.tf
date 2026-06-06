module "eks_helm_jenkins" {
  source = "../"

  environment             = "dev"
  github_org_display_name = "Spartan"
  shared_lib_name         = "spartan"

  domain                         = "example.com"
  github_org                     = "spartan"
  github_app_oauth_client_id     = "spartan"
  github_app_oauth_client_secret = "super-secure"
  jenkins_shared_lib_repo        = "infra-jenkins"
  general_secrets = {
    "secret" = "value"
  }
  jenkins_base_agent_image_repo = "jenkins"
  jenkins_base_agent_image_name = "jenkins-agent"
  jenkins_base_agent_image_tag  = "latest"
  efs_id                        = "fs-12345678"
  jenkins_env_var               = "jenkins-env-var"
  enabled_slack_notification    = false
  enabled_github_app_login      = true
  jenkins_admins                = ["spartan-P00006-admin", "spartan-P00006-iaas"]
  jenkins_executors             = ["spartan-P00006-leader", "spartan-P00006-member"]

  enabled_init_scripts = true
  enabled_datadog      = false

  google_user_list = {
    admin    = ["spartan-admin"]
    executor = ["spartan-leader"]
    viewer   = ["spartan-member"]
  }
}
