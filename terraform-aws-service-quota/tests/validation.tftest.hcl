mock_provider "aws" {}

run "invalid_quota_code" {
  command = plan

  variables {
    quotas = {
      bad = { service_code = "ec2", quota_code = "l-1216c47a", value = 10 }
    }
  }

  expect_failures = [var.quotas]
}

run "negative_value" {
  command = plan

  variables {
    quotas = {
      negative = { service_code = "ec2", quota_code = "L-1216C47A", value = -1 }
    }
  }

  expect_failures = [var.quotas]
}
