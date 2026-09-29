output "hostnames" {
  value = module.eks_multi_tenant_alb.hostnames
}

# Point the hosts at this name in the DNS system you use.
output "dns_name" {
  value = module.eks_multi_tenant_alb.dns_name
}
