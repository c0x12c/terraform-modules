output "r53_main_zone_id" {
  description = "The unique identifier of the main Route 53 DNS zone"
  value       = try(aws_route53_zone.dns_zone[0].zone_id, data.aws_route53_zone.dns_zone[0].zone_id)
}

output "r53_main_zone_name" {
  description = "The DNS name of the main Route 53 zone"
  value       = try(aws_route53_zone.dns_zone[0].name, data.aws_route53_zone.dns_zone[0].name)
}

output "first_record_fqdn" {
  description = "Fully qualified domain name (FQDN) of the first Route 53 record, if available"
  value       = length(aws_route53_record.main) > 0 ? values(aws_route53_record.main)[0].fqdn : null
}

output "r53_main_name_servers" {
  description = "A list of name servers in associated (or default) delegation set."
  value       = try(aws_route53_zone.dns_zone[0].name_servers, data.aws_route53_zone.dns_zone[0].name_servers)
}
