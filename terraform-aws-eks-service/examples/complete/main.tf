module "eks_service" {
  source = "../.."

  cluster_name = "my-eks-cluster"
  eks_oidc_provider = {
    arn = "arn:aws:iam::123456789012:oidc-provider/my-eks-cluster-oidc-provider"
    url = "https://oidc.github.com/id/example-id-1234"
  }
  alb_dns = "my-alb-dns"
  service = {
    name      = "my-service"
    namespace = "my-namespace"
    hostnames = ["my-service.example.com"]
    config_map = {
      "HELLO" = "WORLD"
    }
    secrets = {
      "SECRET" = "super-secret"
    }
    create_service_account = false
    service_account_name   = "default"
  }
  route53_zone_id = "my-route53-zone-id"
  region          = "us-west-2"

  keda_role_arn = null

  assume_custom_roles = [
    {
      sid         = "AssumeRoleSchedulerManagement"
      effect      = "Allow"
      actions     = ["sts:AssumeRole"]
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
      condition = {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = ["source-arn"]
      }
    },
    {
      sid      = "PassRoleToEventBridgeScheduler"
      effect   = "Allow"
      actions  = ["iam:GetRole", "iam:PassRole"]
      resource = "arn:aws:iam::<account-id>:role/<role-name>"
    }
  ]
}
