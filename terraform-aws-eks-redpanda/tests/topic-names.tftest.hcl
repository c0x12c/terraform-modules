mock_provider "aws" {}
mock_provider "kubernetes" {}
mock_provider "helm" {}
mock_provider "random" {}
mock_provider "cloudinit" {}

variables {
  eks_cluster_name = "example"
}

run "accepts_dotted_topic" {
  command = plan
  variables {
    tenants = { alpha = { topics = { "events.ingestion.dlq" = {} } } }
  }

  assert {
    condition     = contains(keys(yamldecode(helm_release.cluster.values[0]).topics), "alpha.events.ingestion.dlq")
    error_message = "Rendered chart values must contain the fully prefixed dotted topic name."
  }
}

run "rejects_leading_dot" {
  command = plan
  variables {
    tenants = { alpha = { topics = { ".dlq" = {} } } }
  }
  expect_failures = [var.tenants]
}

run "rejects_trailing_dot" {
  command = plan
  variables {
    tenants = { alpha = { topics = { "dlq." = {} } } }
  }
  expect_failures = [var.tenants]
}

run "rejects_consecutive_dots" {
  command = plan
  variables {
    tenants = { alpha = { topics = { "a..b" = {} } } }
  }
  expect_failures = [var.tenants]
}

run "rejects_uppercase" {
  command = plan
  variables {
    tenants = { alpha = { topics = { "DLQ" = {} } } }
  }
  expect_failures = [var.tenants]
}

run "rejects_trailing_hyphen" {
  command = plan
  variables {
    tenants = { alpha = { topics = { "dlq-" = {} } } }
  }
  expect_failures = [var.tenants]
}

run "rejects_label_over_63_characters" {
  command = plan
  variables {
    tenants = { alpha = { topics = { "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" = {} } } }
  }
  expect_failures = [var.tenants]
}
