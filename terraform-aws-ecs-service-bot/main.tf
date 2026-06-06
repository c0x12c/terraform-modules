module "main" {
  source  = "c0x12c/ecs-application/aws"
  version = "~> 2.0.1"

  name        = var.service_name
  environment = var.environment
  region      = var.region

  # ECS Configuration
  ecs_cluster_id   = var.ecs_cluster_id
  ecs_cluster_name = var.ecs_cluster_name
  vpc_id           = var.vpc_id
  subnet_ids       = var.subnet_ids

  # Task Configuration
  task_cpu               = var.task_cpu
  task_memory            = var.task_memory
  container_cpu          = var.container_cpu
  container_memory       = var.container_memory
  container_port         = var.container_port
  container_image        = var.service_bot_image
  service_desired_count  = var.service_desired_count
  service_max_capacity   = var.service_max_capacity
  enable_autoscaling     = var.enable_autoscaling
  enable_execute_command = var.enable_execute_command
  health_check_path      = var.health_check_path
  health_check_enabled   = var.health_check_enabled
  force_new_deployment   = var.force_new_deployment
  assign_public_ip       = var.assign_public_ip

  # IAM
  ecs_execution_policy_arns  = var.ecs_execution_policy_arns
  additional_iam_policy_arns = var.additional_iam_policy_arns

  # ALB & Route53
  alb_dns_name                  = var.alb_dns_name
  alb_security_groups           = var.alb_security_groups
  aws_lb_listener_arn           = var.aws_lb_listener_arn
  aws_lb_listener_rule_priority = var.aws_lb_listener_rule_priority
  alb_zone_id                   = var.alb_zone_id
  dns_name                      = var.dns_name
  route53_zone_id               = var.route53_zone_id

  # Environment Variables and Secrets (defined in locals.tf)
  container_environment = local.container_environment
  container_secrets     = local.container_secrets

  # Notification
  enabled_notification                = var.enabled_notification
  slack_webhook_url                   = var.slack_webhook_url
  notification_deployment_event_types = var.notification_deployment_event_types
  notification_service_event_types    = var.notification_service_event_types
  notification_task_stop_codes        = var.notification_task_stop_codes

  # Datadog
  enabled_datadog_sidecar = var.enabled_datadog_sidecar
  dd_site                 = var.dd_site
  dd_api_key_arn          = var.dd_api_key_arn
  dd_agent_image          = var.dd_agent_image
  dd_port                 = var.dd_port
  dd_sidecar_environment  = var.dd_sidecar_environment

  launch_type = var.launch_type
}
