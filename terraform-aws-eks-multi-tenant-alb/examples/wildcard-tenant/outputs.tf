output "hostnames" {
  value = module.eks_multi_tenant_alb.hostnames
}

output "certificate_arns" {
  value = module.eks_multi_tenant_alb.certificate_arns
}
