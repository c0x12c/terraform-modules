<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.46.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_airflow"></a> [airflow](#module\_airflow) | ../terraform-datadog-monitors | n/a |
| <a name="module_billing"></a> [billing](#module\_billing) | ../terraform-datadog-monitors | n/a |
| <a name="module_elasticache"></a> [elasticache](#module\_elasticache) | ../terraform-datadog-monitors | n/a |
| <a name="module_emr"></a> [emr](#module\_emr) | ../terraform-datadog-monitors | n/a |
| <a name="module_kinesis"></a> [kinesis](#module\_kinesis) | ../terraform-datadog-monitors | n/a |
| <a name="module_msk"></a> [msk](#module\_msk) | ../terraform-datadog-monitors | n/a |
| <a name="module_rds"></a> [rds](#module\_rds) | ../terraform-datadog-monitors | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_db_name_regex"></a> [db\_name\_regex](#input\_db\_name\_regex) | Define database name to filter by datadog monitors, it will collects multiple datase in case it is `*` | `string` | `"*"` | no |
| <a name="input_enabled_modules"></a> [enabled\_modules](#input\_enabled\_modules) | List of modules to enable, must be one of billing, elasticache, rds | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment monitored by this module | `string` | n/a | yes |
| <a name="input_notification_slack_channel_prefix"></a> [notification\_slack\_channel\_prefix](#input\_notification\_slack\_channel\_prefix) | The prefix for Slack channels that will receive notifications and alerts | `string` | n/a | yes |
| <a name="input_override_default_monitors"></a> [override\_default\_monitors](#input\_override\_default\_monitors) | Override default monitors with custom configuration | `map(map(any))` | `{}` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Service tag to filter RDS query (trace) monitors by. `*` matches all services. | `string` | `"*"` | no |
| <a name="input_tag_slack_channel"></a> [tag\_slack\_channel](#input\_tag\_slack\_channel) | Whether to tag the Slack channel in the message | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->