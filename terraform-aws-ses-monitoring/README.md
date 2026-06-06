## Usage

module "main" {
  source  = "c0x12c/ses-monitoring/aws"
  version = "~> 1.0.0"

  environment      = "dev"
  name             = replace("example1.com", ".", "_")

  ses_identity_ids = {
    "<ses-id>": "<ses-identity-id>"
  }

  datadog_api_key                       = "<datadog-api-key>"
  datadog_site                          = "https://us3.datadoghq.com/"
  enabled_datadog_dashboard             = true
  datadog_dashboard_environments        = ["dev", "prod"]
  datadog_dashboard_default_environment = "dev"

  enabled_outgoing_email_logs_cloudwatch = true
}

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | ~> 3.69.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog_dashboard"></a> [datadog\_dashboard](#module\_datadog\_dashboard) | c0x12c/dashboard/datadog | ~> 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.sns_invoke_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_ses_identity_notification_topic.bounce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_identity_notification_topic) | resource |
| [aws_ses_identity_notification_topic.complaint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_identity_notification_topic) | resource |
| [aws_ses_identity_notification_topic.delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_identity_notification_topic) | resource |
| [aws_sns_topic.ses_notification_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.sns_lambda_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | The datadog api key | `string` | n/a | yes |
| <a name="input_datadog_dashboard_default_environment"></a> [datadog\_dashboard\_default\_environment](#input\_datadog\_dashboard\_default\_environment) | The default environments to enable the Datadog dashboard for. | `string` | `"prod"` | no |
| <a name="input_datadog_dashboard_environments"></a> [datadog\_dashboard\_environments](#input\_datadog\_dashboard\_environments) | The environments to enable the Datadog dashboard for. | `list(string)` | <pre>[<br/>  "dev",<br/>  "prod"<br/>]</pre> | no |
| <a name="input_datadog_site"></a> [datadog\_site](#input\_datadog\_site) | The datadog site | `string` | `"datadoghq.com"` | no |
| <a name="input_enabled_datadog_dashboard"></a> [enabled\_datadog\_dashboard](#input\_enabled\_datadog\_dashboard) | Whether to enable the Datadog dashboard. | `bool` | `false` | no |
| <a name="input_enabled_outgoing_email_logs_cloudwatch"></a> [enabled\_outgoing\_email\_logs\_cloudwatch](#input\_enabled\_outgoing\_email\_logs\_cloudwatch) | Whether to enable the SES outgoing email logs on CloudWatch. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment of the outgoing logs | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the outgoing logs | `string` | n/a | yes |
| <a name="input_ses_identity_ids"></a> [ses\_identity\_ids](#input\_ses\_identity\_ids) | Map of SES identity IDs | `map(string)` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->