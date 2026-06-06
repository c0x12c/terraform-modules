output "cluster_arn" {
  value = module.msk.cluster_arn
}

output "bootstrap_brokers_sasl_iam" {
  value = module.msk.bootstrap_brokers_sasl_iam
}

output "zookeeper_connect_string" {
  value = module.msk.zookeeper_connect_string
}
