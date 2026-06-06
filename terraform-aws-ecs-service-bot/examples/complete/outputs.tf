output "ecs_service_name" {
  description = "ECS service name"
  value       = module.service_bot.ecs_service_name
}

output "alb_target_group_arn" {
  description = "ALB target group ARN"
  value       = module.service_bot.alb_target_group_arn
}

output "application_domain_name" {
  description = "Route53 record FQDN"
  value       = module.service_bot.application_domain_name
}

output "task_role_arn" {
  description = "Task role ARN"
  value       = module.service_bot.task_role_arn
}

output "container_definitions" {
  description = "Container definitions"
  value       = module.service_bot.container_definitions
}
