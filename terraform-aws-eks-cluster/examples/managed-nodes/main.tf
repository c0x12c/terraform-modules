locals {
  environment = "dev"
  name        = "spartan"
}

module "eks" {
  source = "../.."

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

  # node groups
  node_groups = {
    "g1" = {
      node_group_name = "group1"
      disk_size       = 20
      instance_types  = ["t3a.medium"]
      desired_size    = "1"
      min_size        = "1"
      max_size        = "5"
      labels          = {}
      taints          = []
    }
  }
  custom_namespaces = ["jenkins", "datadog", "service-bot"]

  # custom RBAC
  administrator_role_arn = null
  aws_auth_users         = []

  coredns = {
    replica_count = 1
    node_selector = {
      "service-type" = "backbone"
    }
    tolerations = [
      {
        key      = "service-type"
        value    = "backbone"
        effect   = "NoSchedule"
        operator = "Equal"
      }
    ]
  }

  efs_csi = {
    replica_count = 1
    node_selector = {
      "service-type" = "backbone"
    }
    tolerations = [
      {
        key      = "service-type"
        value    = "backbone"
        effect   = "NoSchedule"
        operator = "Equal"
      }
    ]
  }
}
