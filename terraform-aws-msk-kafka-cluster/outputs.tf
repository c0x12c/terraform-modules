output "cluster_arn" {
  description = "The ARN of the MSK cluster."
  value       = aws_msk_cluster.this.arn
}

output "cluster_name" {
  description = "The name of the MSK cluster."
  value       = aws_msk_cluster.this.cluster_name
}

output "current_version" {
  description = "The current version of the MSK cluster. Used for in-place updates."
  value       = aws_msk_cluster.this.current_version
}

output "bootstrap_brokers" {
  description = "Comma-separated list of plaintext broker endpoints."
  value       = aws_msk_cluster.this.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "Comma-separated list of TLS broker endpoints."
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}

output "bootstrap_brokers_sasl_iam" {
  description = "Comma-separated list of SASL/IAM broker endpoints."
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
}

output "bootstrap_brokers_sasl_scram" {
  description = "Comma-separated list of SASL/SCRAM broker endpoints."
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
}

output "zookeeper_connect_string" {
  description = "A comma-separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster."
  value       = aws_msk_cluster.this.zookeeper_connect_string
}

output "configuration_arn" {
  description = "ARN of the MSK configuration created by this module, if any."
  value       = try(aws_msk_configuration.this[0].arn, null)
}

output "configuration_latest_revision" {
  description = "Latest revision of the MSK configuration created by this module, if any."
  value       = try(aws_msk_configuration.this[0].latest_revision, null)
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group created for broker logs, if any."
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}
