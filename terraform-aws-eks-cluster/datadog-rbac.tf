module "datadog_rbac" {
  count   = var.create_fargate_profile == true && var.enabled_datadog_agent == true ? 1 : 0
  source  = "c0x12c/eks-datadog-rbac/aws"
  version = "1.2.0"

  default_service_account         = var.default_service_account
  custom_service_accounts         = var.custom_service_accounts
  datadog_agent_cluster_role_name = var.datadog_agent_cluster_role_name
}
