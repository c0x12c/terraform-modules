output "dns_name" {
  description = "DNS name of the ALB."
  value       = kubernetes_ingress_v1.alb.status[0].load_balancer[0].ingress[0].hostname
}

output "zone_id" {
  description = "Route53 hosted zone ID of the ALB, for alias records."
  value       = data.aws_lb_hosted_zone_id.this.id
}

output "group_name" {
  description = "Ingress group name of the ALB. Add an ingress with this group name to put more rules on the same ALB."
  value       = var.name
}

output "certificate_arns" {
  description = "ARN of each certificate the module created, by certificate domain (e.g. \"*.acme.example.com\"). Empty when create_certificates is false."
  value       = { for domain, cert in module.acm : domain => cert.acm_certificate_arn }
}

output "cloudfront_certificate_arns" {
  description = "ARN of each us-east-1 certificate the module created for CloudFront, by certificate domain. Empty when create_cloudfront_cert is false."
  value       = { for domain, cert in aws_acm_certificate_validation.cloudfront : domain => cert.certificate_arn }
}

output "hosted_zone_ids" {
  description = "Route53 hosted zone ID of each tenant sub-zone, by tenant name. Empty when create_hosted_zone is false."
  value       = { for tenant, zone in aws_route53_zone.tenant : tenant => zone.zone_id }
}

output "hosted_zone_name_servers" {
  description = "Name servers of each tenant sub-zone, by tenant name. Use these to verify delegation when parent_zone_id is not managed here."
  value       = { for tenant, zone in aws_route53_zone.tenant : tenant => zone.name_servers }
}

output "hostnames" {
  description = "Full host name of each route, by \"<tenant>/<service>\"."
  value       = { for key, route in local.routes : key => route.host }
}
