# example
locals {
  eks_cluster = {
    cluster_name = "example-dev"
    oidc_provider = {
      url = "https://server.example.com/oidc/xxx"
      arn = "arn:aws:iam::123456789012:oidc-provider/server.example.com"
    }
  }
}

module "aws_eks_lb" {
  source = "../../"

  cluster_name        = local.eks_cluster.cluster_name
  oidc_provider       = local.eks_cluster.oidc_provider
  certificate_arn     = ["arn:aws:acm:Region:123456789012:certificate/certificate_ID"]
  private_subnet      = ["subnet-abcd", "subnet-cdef"]
  public_subnet       = ["subnet-01234", "subnet-23456"]
  vpc_id              = "vpc-xxx"
  enable_internal_alb = true
  region              = "us-west-2"
  node_selector       = {}
  tolerations         = []
}

