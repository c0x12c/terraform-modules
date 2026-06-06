output "external_alb_cname" {
  value       = kubernetes_ingress_v1.external_alb.status.0.load_balancer.0.ingress.0.hostname
  description = "CNAME address of external aws load balancer"
}

output "external_group_name" {
  value       = kubernetes_ingress_v1.external_alb.metadata.0.annotations["alb.ingress.kubernetes.io/group.name"]
  description = "Group name of external aws load balancer"
}

output "internal_alb_cname" {
  value       = try(kubernetes_ingress_v1.internal_alb[0].status.0.load_balancer.0.ingress.0.hostname, null)
  description = "CNAME address of internal aws load balancer"
}

output "internal_group_name" {
  value       = try(kubernetes_ingress_v1.internal_alb[0].metadata.0.annotations["alb.ingress.kubernetes.io/group.name"], null)
  description = "Group name of internal aws load balancer"
}
