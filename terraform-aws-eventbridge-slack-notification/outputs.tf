output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.notifier.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.notifier.function_name
}

output "iam_role_arn" {
  description = "ARN of the Lambda execution IAM role"
  value       = aws_iam_role.lambda_exec_role.arn
}

output "iam_role_name" {
  description = "Name of the Lambda execution IAM role"
  value       = aws_iam_role.lambda_exec_role.name
}

output "event_rule_arns" {
  description = "ARNs of the CloudWatch Event Rules"
  value       = { for k, v in aws_cloudwatch_event_rule.this : k => v.arn }
}
