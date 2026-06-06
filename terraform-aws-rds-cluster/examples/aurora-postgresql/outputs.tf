output "endpoint" {
  value = module.cluster.endpoint
}

output "reader_endpoint" {
  value = module.cluster.reader_endpoint
}

output "master_user_secret_arn" {
  value = module.cluster.master_user_secret_arn
}
