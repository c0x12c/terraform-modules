output "sqs_queue" {
  value = module.sqs.queue
}

output "sqs_dlq" {
  value = module.sqs.dlq
}

output "sqs_iam_policy_sqs_write_arn" {
  value = module.sqs.iam_policy_sqs_write_arn
}

output "sqs_iam_policy_sqs_read_arn" {
  value = module.sqs.iam_policy_sqs_read_arn
}
