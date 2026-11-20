provider "aws" {
  region = "us-west-2"
}

locals {
  # Example values: set each value to what your account applies today when adopting,
  # or to the value you want when raising. Find codes in docs/service-quotas/ of this repo.
  quotas = {
    fargate_on_demand_vcpus = {
      service_code = "fargate"
      quota_code   = "L-3032A538"
      value        = 60
    }
    ec2_on_demand_standard_vcpus = {
      service_code = "ec2"
      quota_code   = "L-1216C47A"
      value        = 96
    }
  }
}

module "service_quotas" {
  source = "../../"

  quotas = local.quotas
}

# Adopts quotas that were already raised in the console, so the first apply submits no
# increase request. Remove this block after the first apply.
import {
  for_each = local.quotas
  to       = module.service_quotas.aws_servicequotas_service_quota.this[each.key]
  id       = "${each.value.service_code}/${each.value.quota_code}"
}
