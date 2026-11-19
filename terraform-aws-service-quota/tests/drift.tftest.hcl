# The mock provider stands in for AWS; override_data sets the value AWS applies so each
# run models one request outcome. Drift runs expect the check to fail: a check only warns
# in a real plan, and expect_failures is how terraform test asserts that warning.
mock_provider "aws" {}

variables {
  quotas = {
    fargate_on_demand_vcpus = { service_code = "fargate", quota_code = "L-3032A538", value = 100 }
  }
}

run "in_sync" {
  command = plan

  override_data {
    target = data.aws_servicequotas_service_quota.applied["fargate_on_demand_vcpus"]
    values = { value = 100, default_value = 6 }
  }

  assert {
    condition     = length(output.quotas_out_of_sync) == 0
    error_message = "A quota whose applied value equals code must not be reported out of sync."
  }

  assert {
    condition     = output.quotas["fargate_on_demand_vcpus"].applied_value == 100
    error_message = "quotas output must expose the applied value read from AWS."
  }
}

run "partial_approval" {
  command = plan

  override_data {
    target = data.aws_servicequotas_service_quota.applied["fargate_on_demand_vcpus"]
    values = { value = 50, default_value = 6 }
  }

  expect_failures = [check.quotas_match_code]

  assert {
    condition     = output.quotas_out_of_sync["fargate_on_demand_vcpus"] == { code_value = 100, applied_value = 50 }
    error_message = "An approval below the requested value must be reported with both values."
  }
}

run "denied" {
  command = plan

  override_data {
    target = data.aws_servicequotas_service_quota.applied["fargate_on_demand_vcpus"]
    values = { value = 6, default_value = 6 }
  }

  expect_failures = [check.quotas_match_code]

  assert {
    condition     = output.quotas_out_of_sync["fargate_on_demand_vcpus"] == { code_value = 100, applied_value = 6 }
    error_message = "A denied request leaves the default applied and must be reported."
  }
}

run "raised_outside_terraform" {
  command = plan

  override_data {
    target = data.aws_servicequotas_service_quota.applied["fargate_on_demand_vcpus"]
    values = { value = 200, default_value = 6 }
  }

  expect_failures = [check.quotas_match_code]

  assert {
    condition     = output.quotas_out_of_sync["fargate_on_demand_vcpus"] == { code_value = 100, applied_value = 200 }
    error_message = "A quota raised in the console above code must be reported."
  }
}
