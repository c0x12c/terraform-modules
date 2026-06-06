output "alb_target_group_arn" {
  description = "The ALB ARN of ECS application"
  value       = try(aws_lb_target_group.this[0].arn, null)
}

output "application_domain_name" {
  description = "The domain name of ECS application"
  value       = try(aws_route53_record.this[0].fqdn, null)
}

output "ecs_service_name" {
  description = "The ECS service name"
  value       = aws_ecs_service.this.name
}

output "container_definitions" {
  description = "The container definitions of ECS application"
  value       = local.container_definitions
}

output "additional_container_definitions" {
  description = "The additional container definitions of ECS application"
  value       = var.additional_container_definitions
}

output "task_role_arn" {
  description = "The task role arn"
  value       = aws_iam_role.task_role.arn
}
