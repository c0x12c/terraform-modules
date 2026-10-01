output "hostnames" {
  value = module.eks_multi_tenant_alb.hostnames
}

output "dns_name" {
  value = module.eks_multi_tenant_alb.dns_name
}
