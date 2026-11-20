output "quotas" {
  description = "Per quota key: the value in code, the value AWS applies now, the AWS default, quota and service names, ARN, whether the quota is adjustable, and the ID and status of the last increase request Terraform submitted."
  value = {
    for key, quota in var.quotas : key => {
      value          = quota.value
      applied_value  = data.aws_servicequotas_service_quota.applied[key].value
      default_value  = data.aws_servicequotas_service_quota.applied[key].default_value
      quota_name     = data.aws_servicequotas_service_quota.applied[key].quota_name
      service_name   = data.aws_servicequotas_service_quota.applied[key].service_name
      arn            = data.aws_servicequotas_service_quota.applied[key].arn
      adjustable     = data.aws_servicequotas_service_quota.applied[key].adjustable
      request_id     = aws_servicequotas_service_quota.this[key].request_id
      request_status = aws_servicequotas_service_quota.this[key].request_status
    }
  }
}

output "quotas_out_of_sync" {
  description = "Quotas whose AWS-applied value differs from code, as { code_value, applied_value } per key; empty when in sync. Re-export it from the root module to read it with `terraform output`, which shows what the last apply saw; a plan shows the current state."
  value       = local.quotas_out_of_sync
}
