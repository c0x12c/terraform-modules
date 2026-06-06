output "dns_name" {
  value = module.alb.dns_name
}

output "zone_id" {
  value = module.alb.zone_id
}

output "listener_https_arn" {
  value = module.alb.listener_https_arn
}

output "security_group_id" {
  value = module.alb.security_group_id
}

output "arn" {
  value = module.alb.arn
}
