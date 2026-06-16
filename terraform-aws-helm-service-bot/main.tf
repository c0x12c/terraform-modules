module "eks_service" {
  source = "../terraform-aws-eks-service"

  cluster_name      = var.cluster_name
  eks_oidc_provider = var.eks_oidc_provider

  region          = var.region
  route53_zone_id = var.route53_zone_id

  alb_dns = var.alb_dns
  service = {
    name      = var.service_name
    namespace = var.namespace
    hostnames = [var.app_domain]

    config_map = {
      # required config map entries
      MICRONAUT_ENVIRONMENTS = var.environment
      HTTP_CLIENT_LOG_LEVEL  = var.http_client_log_level
      APP_DOMAIN             = var.app_domain
      SLACK_BOT_USER_ID      = var.slack_bot_user_id
      ALLOWED_SLACK_CHANNEL  = var.allowed_slack_channel
      ON_CALL_SLACK_CHANNEL  = var.on_call_slack_channel
      SLACK_USER_GROUP_NAMES = var.slack_user_group_names
      SLACK_CHANNEL_PREFIX   = var.slack_channel_prefix

      CENTRALIZED_RELEASE_SLACK_CHANNEL = var.centralized_release_slack_channel
      GITHUB_ORG                        = var.github_org
      GITHUB_REPO_LIST                  = join(",", concat(var.app_repo_list, var.infra_repo_list))
      APP_REPO_LIST                     = join(",", var.app_repo_list)
      INFRA_REPO_LIST                   = join(",", var.infra_repo_list)

      # optional config map entries
      ATLASSIAN_HOST             = var.atlassian_host
      JENKINS_USERNAME           = var.jenkins_username
      JENKINS_HOST               = var.jenkins_host
      JENKINS_REPOSITORY         = var.jenkins_repository
      ATLASSIAN_USERNAME         = var.atlassian_username
      ATLASSIAN_PAGE_PATH_PREFIX = var.atlassian_page_path_prefix
      SPACE_ID                   = var.space_id
      ON_CALL_PAGE_ID            = var.on_call_page_id
      ON_CALL_TEMPLATE_PAGE_ID   = var.on_call_template_page_id
      ON_CALL_PROCESS_PAGE_ID    = var.on_call_process_page_id
    }

    secrets = {
      # required secrets
      SLACK_SIGNING_SECRET = var.slack_signing_secret
      SLACK_BOT_TOKEN      = var.slack_bot_token
      SLACK_USER_TOKEN     = var.slack_user_token

      GITHUB_APP_ID              = var.github_app_id
      GITHUB_APP_INSTALLATION_ID = var.github_app_installation_id
      GITHUB_APP_PRIVATE_KEY     = var.github_app_private_key

      # optional secrets
      JENKINS_API_TOKEN   = var.jenkins_api_token
      ATLASSIAN_API_TOKEN = var.atlassian_api_token
    }

    create_service_account = true

    service_account_name = var.service_name
  }
  create_kubernetes_namespace = true
}

resource "helm_release" "service_bot" {
  name       = var.service_name
  repository = "https://spartan-stratos.github.io/helm-charts"
  chart      = "spartan"
  namespace  = var.namespace
  version    = var.spartan_chart_version

  depends_on = [module.eks_service]

  values = [
    yamlencode({
      replicaCount = 1
      image = {
        repository = var.service_bot_image_repository
        tag        = var.service_bot_image_tag
      }

      fullnameOverride = var.service_name
      containerName    = var.service_name
      appNameLabel     = var.service_name

      serviceAccount = {
        create = false
        name   = var.service_name
      }

      ingress = {
        enabled   = true
        className = "alb"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
          "alb.ingress.kubernetes.io/group.name"       = "external"
          "kubernetes.io/ingress.class"                = "alb"
          "alb.ingress.kubernetes.io/target-type"      = "ip"
          "alb.ingress.kubernetes.io/healthcheck-path" = "/api/v1/health-check"
          "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
        }

        hosts = [
          {
            host = var.app_domain
            paths = [
              {
                path     = "/*"
                pathType = "ImplementationSpecific"
              }
            ]
          }
        ]
      }

      resources = var.service_resources

      livenessProbe = {
        httpGet = {
          path = "/health"
          port = 8080
        }
      }
      readinessProbe = {
        httpGet = {
          path = "/health"
          port = 8080
        }
      }

      autoscaling = {
        enabled = false
      }

      configMap = {
        externalConfigMapEnv = {
          enabled = true
          name    = "${var.service_name}-config-map"
        }
      }

      secret = {
        externalSecretEnv = {
          enabled = true
          name    = "${var.service_name}-env-var"
        }
      }

      extraEnvs = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]
    })
  ]
}
