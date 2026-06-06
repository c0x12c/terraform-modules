output "r53_main_zone_id" {
  value = module.route53.r53_main_zone_id
}

output "r53_main_zone_name" {
  value = module.route53.r53_main_zone_name
}

output "first_record_fqdn" {
  value = module.route53.first_record_fqdn
}

output "r53_main_name_servers" {
  value = module.route53.r53_main_name_servers
}
