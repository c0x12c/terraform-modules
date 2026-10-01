output "tenant_hosted_zones" {
  description = "Tenant sub-zone IDs."
  value       = module.eks_multi_tenant_alb.hosted_zone_ids
}

output "tenant_certificate_arns" {
  description = "us-west-2 certificate ARNs attached to the tenant ALB."
  value       = module.eks_multi_tenant_alb.certificate_arns
}

output "tenant_cloudfront_certificate_arns" {
  description = "us-east-1 certificate ARNs to attach to the webapp CloudFront distribution."
  value       = module.eks_multi_tenant_alb.cloudfront_certificate_arns
}
