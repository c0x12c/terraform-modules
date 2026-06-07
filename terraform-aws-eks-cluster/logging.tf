module "cloudwatch_logging" {
  source = "../terraform-aws-eks-cloudwatch-logging-fargate"

  count                                   = var.create_fargate_profile == true && var.enabled_cloudwatch_logging == true ? 1 : 0
  name                                    = local.cluster_name
  region                                  = local.region
  fargate_profile_pod_execution_role_name = module.fargate_profile.fargate_profile_pod_execution_role_name

  depends_on = [module.fargate_profile]
}
