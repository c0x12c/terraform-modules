output "application_domain_name" {
  description = "Route53 record FQDN"
  value       = module.service_bot.application_domain_name
}
