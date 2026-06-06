module "eks" {
  source = "../../"

  region          = "us-west-2"
  environment     = "test"
  cluster_version = "1.28"
  name            = "example"

  # networking
  security_group_ids = []
  vpc_id             = "vpc-123456"
  vpc_cidr           = "0.0.0.0/0"
  public_subnet_ids  = ["subnet-abcde012"]
  private_subnet_ids = ["subnet-abcde014"]

  # feature flags
  enabled_cluster_log_types  = []
  enabled_cloudwatch_logging = false
  create_fargate_profile     = true
  enabled_datadog_agent      = true
  enabled_efs                = true

  # fargate
  fargate_profiles = {
    default = {
      selectors = [
        {
          namespace = "*"
        }
      ]
    }
  }

  fargate_timeouts = {
    create = "20m"
    delete = "20m"
  }

  custom_namespaces = ["jenkins", "datadog", "service-bot"]
  compute_type      = "fargate"

  # custom RBAC
  administrator_role_arn = null
  aws_auth_users         = []
}
