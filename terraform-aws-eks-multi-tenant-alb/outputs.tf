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

output "hostnames" {
  description = "Full host name of each route, by \"<tenant>/<service>\"."
  value       = { for key, route in local.routes : key => route.host }
}
