module "eks_datadog_rbac" {
  source = "../../"

  create_datadog_agent_cluster_role = true

  custom_service_accounts = {
    namespace = ["service-account"]
  }

  datadog_agent_cluster_role_name = "datadog-agent"
  enable_default_service_accounts = false
}
