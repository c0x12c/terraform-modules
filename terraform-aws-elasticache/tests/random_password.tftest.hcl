mock_provider "aws" {}
mock_provider "random" {}

variables {
  cluster_name                           = "example"
  subnet_ids                             = ["subnet-1234567899a"]
  node_type                              = "cache.t4g.micro"
  cache_node_count                       = 1
  security_group_allow_all_within_vpc_id = "sg-1234567899"
  transit_encryption_enabled             = true
}

run "default_has_no_legacy_random_string" {
  command = plan

  assert {
    condition     = length(random_string.this) == 0
    error_message = "random_string must not be created by default"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "random_password must generate the auth token"
  }
}

run "flag_keeps_legacy_random_string" {
  command = plan

  variables {
    keep_legacy_random_string = true
  }

  assert {
    condition     = length(random_string.this) == 1
    error_message = "random_string must be kept while migrating"
  }
}
