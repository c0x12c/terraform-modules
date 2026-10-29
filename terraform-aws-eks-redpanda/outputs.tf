output "bootstrap_brokers" {
  description = "Kafka bootstrap address inside the EKS cluster (SASL SCRAM-SHA-512)."
  value       = local.brokers_address
}

output "namespace" {
  description = "Namespace holding the cluster and its Secrets."
  value       = var.namespace
}

output "admin_secret_name" {
  description = "Secret with the superuser's username, password and mechanism. Operators only."
  value       = local.admin_secret
}

output "tenant_secret_names" {
  description = "Per-tenant Secret (username, password, mechanism, brokers), keyed by tenant."
  value       = local.tenant_secrets
}

output "tenant_topics" {
  description = "Topics created for tenants, fully qualified."
  value       = keys(local.topics)
}

output "brokers" {
  description = "Effective broker sizing after profile and overrides."
  value       = local.brokers
}

output "node_group_names" {
  description = "Dedicated broker node groups, keyed by subnet id."
  value       = { for k, ng in aws_eks_node_group.this : k => ng.node_group_name }
}

output "tiered_storage_bucket" {
  description = "S3 bucket used for tiered storage, or null."
  value       = local.tiered_bucket
}

output "tiered_storage_role_arn" {
  description = "IRSA role the brokers use for S3, or null."
  value       = try(aws_iam_role.tiered[0].arn, null)
}
