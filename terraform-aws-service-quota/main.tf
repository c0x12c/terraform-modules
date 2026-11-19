# Each quota is managed by the resource, which submits an increase request when `value`
# exceeds what AWS applies. The resource cannot tell an approved request from a denied or
# partially approved one once the request leaves PENDING, so the data source below reads
# the applied value from AWS on every plan and the check reports any mismatch.

resource "aws_servicequotas_service_quota" "this" {
  for_each = var.quotas

  service_code = each.value.service_code
  quota_code   = each.value.quota_code
  value        = each.value.value
}

# Read on every plan, including `plan -refresh=false`, so drift is reported even when the
# resource state is not refreshed. Returns the default value when the quota was never raised.
data "aws_servicequotas_service_quota" "applied" {
  for_each = var.quotas

  service_code = each.value.service_code
  quota_code   = each.value.quota_code
}

locals {
  quotas_out_of_sync = {
    for key, quota in var.quotas : key => {
      code_value    = quota.value
      applied_value = data.aws_servicequotas_service_quota.applied[key].value
    }
    if data.aws_servicequotas_service_quota.applied[key].value != quota.value
  }
}

# A check block only warns: it never blocks plan or apply.
check "quotas_match_code" {
  assert {
    condition = length(local.quotas_out_of_sync) == 0
    error_message = format(
      "Service quotas differ from code: %s. A request submitted in the last few hours may still be pending. Otherwise AWS approved a different value, denied the request, or the quota was changed outside Terraform: set value to the applied value. See the module README.",
      join(", ", [for key, drift in local.quotas_out_of_sync : "${key} (code ${drift.code_value}, applied ${drift.applied_value})"]),
    )
  }
}
