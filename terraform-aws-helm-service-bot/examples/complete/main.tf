provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "service_bot" {
  source      = "../../"
  environment = "dev"

  cluster_name      = var.cluster_name
  eks_oidc_provider = var.eks_oidc_provider
  region            = var.region
  route53_zone_id   = var.route53_zone_id
  alb_dns           = var.alb_dns

  # Slack
  slack_signing_secret  = var.slack_signing_secret
  slack_bot_token       = var.slack_bot_token
  slack_user_token      = var.slack_user_token
  slack_bot_user_id     = var.slack_bot_user_id
  allowed_slack_channel = var.allowed_slack_channel
  slack_channel_prefix  = "prj-"

  # GitHub
  github_org                 = var.github_org
  app_repo_list              = var.app_repo_list
  github_app_id              = var.github_app_id
  github_app_installation_id = var.github_app_installation_id
  github_app_private_key     = var.github_app_private_key

  # Jenkins
  jenkins_username  = var.jenkins_username
  jenkins_api_token = var.jenkins_api_token

  # Atlassian
  atlassian_username  = var.atlassian_username
  atlassian_api_token = var.atlassian_api_token
}
