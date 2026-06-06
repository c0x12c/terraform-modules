data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.datadog_aws_account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        datadog_integration_aws_account.sandbox.auth_config.aws_auth_config_role.external_id
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog_aws_integration" {
  statement {
    actions   = var.datadog_permissions == null ? local.datadog_permissions : var.datadog_permissions
    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name   = "DatadogAWSIntegrationPolicy"
  policy = data.aws_iam_policy_document.datadog_aws_integration.json
}

resource "aws_iam_role" "datadog_aws_integration" {
  name               = var.datadog_aws_integration_iam_role
  description        = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration_managed" {
  for_each   = toset(var.aws_attached_policy_arns)
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = each.value
}

/**
Create and manage Datadog - Amazon Web Services integration.
version = "~> 4.9.0"
https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_account
 */
resource "datadog_integration_aws_account" "sandbox" {
  aws_account_id = data.aws_caller_identity.this.account_id
  aws_partition  = "aws"

  auth_config {
    aws_auth_config_role {
      role_name = var.datadog_aws_integration_iam_role
    }
  }

  aws_regions {}

  logs_config {
    lambda_forwarder {}
  }

  metrics_config {
    enabled = true
    namespace_filters {
      include_only = var.namespace_filters_include_only
      exclude_only = var.namespace_filters_exclude_only
    }
  }

  resources_config {
    extended_collection = var.extended_collection
  }

  traces_config {
    xray_services {}
  }

  lifecycle {
    precondition {
      condition     = !(var.namespace_filters_include_only != null && var.namespace_filters_exclude_only != null)
      error_message = "namespace_filters_include_only and namespace_filters_exclude_only are mutually exclusive; set only one."
    }
  }
}
