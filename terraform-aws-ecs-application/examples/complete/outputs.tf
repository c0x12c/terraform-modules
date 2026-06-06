output "alb_target_group_arn" {
  value = module.this.alb_target_group_arn
}

output "application_domain_name" {
  value = module.this.application_domain_name
}

output "ecs_service_name" {
  value = module.this.ecs_service_name
}

output "container_definitions" {
  value = module.this.container_definitions
}

output "additional_container_definitions" {
  value = module.this.additional_container_definitions
}
