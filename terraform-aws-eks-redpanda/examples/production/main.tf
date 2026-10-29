# Dedicated Graviton brokers on EBS gp3, one node group per AZ, tiered storage to S3 with
# 10 GiB per partition kept locally. Scale up with size, out with brokers.replicas.
module "redpanda" {
  source = "../.."

  name             = "redpanda-shared"
  eks_cluster_name = "example"
  size             = "medium"

  brokers = {
    replicas = 6
  }

  node_group = {
    create     = true
    subnet_ids = ["subnet-0aaaaaaaaaaaaaaaa", "subnet-0bbbbbbbbbbbbbbbb", "subnet-0cccccccccccccccc"]
  }

  oidc_provider = {
    arn = "arn:aws:iam::000000000000:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"
    url = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"
  }

  enterprise_license_secret = {
    name = "redpanda-license"
    key  = "license"
  }

  tiered_storage = {
    enabled               = true
    local_retention_bytes = 10737418240
  }

  tenants = {
    payments = {
      topics = {
        ledger = { partitions = 24, config = { "retention.ms" = "-1" } }
      }
      transactions       = true
      producer_byte_rate = 20971520
    }
    analytics = {
      topics = {
        clickstream = { partitions = 48, config = { "retention.ms" = "604800000" } }
      }
      producer_byte_rate = 10485760
      consumer_byte_rate = 10485760
    }
  }

  tags = {
    Environment = "prod"
  }
}
