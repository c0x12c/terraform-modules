# Cheapest shape: 3 small brokers on the cluster's existing nodes, EBS volumes, no
# licence, two tenants. Roughly the cost of 3 x 50 GiB gp3 plus the node capacity it uses.
module "redpanda" {
  source = "../.."

  eks_cluster_name = "example"

  tenants = {
    acme = {
      topics = {
        orders = { partitions = 6 }
        events = { partitions = 3, config = { "retention.ms" = "86400000" } }
      }
      producer_byte_rate = 1048576
      consumer_byte_rate = 2097152
    }
    beta = {
      topics = {
        orders = {}
      }
    }
  }
}

output "bootstrap_brokers" {
  value = module.redpanda.bootstrap_brokers
}

output "tenant_secret_names" {
  value = module.redpanda.tenant_secret_names
}
