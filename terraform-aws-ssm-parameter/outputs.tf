output "parameter_ids" {
  description = "List of parameter ids"
  value = {
    for k, v in aws_ssm_parameter.this : k => v.id
  }
}

output "parameter_arns" {
  description = "List of parameter ARNs"
  value = {
    for k, v in aws_ssm_parameter.this : k => v.arn
  }
}
