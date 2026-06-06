# Google Monitoring / Logging Metric Terraform module

This Terraform module provisions GCP metric and monitoring rule.

## Usage

### Create Logging Metric and Monitoring Rule

## Examples

- [Example](./examples/)

You may encounter this issue https://github.com/hashicorp/terraform-provider-google/issues/13349.

The Terraform code / provider does not support direct filter without `resource.type`.
You can first bypass it with any `resource_type` to apply; then modify the resource filter directly on GCP console, and
in Terraform source (making sure no changes of Terraform plan).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google)          | >= 6.12  |

## Providers

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12 |

## Modules

No modules.

## Resources

| Name                                                                                                                                          | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [google_logging_metric.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric)                   | resource |
| [google_monitoring_alert_policy.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |

## Inputs

| Name                                                                                                | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Type                                                                                                                                                                   | Default   | Required |
|-----------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|:--------:|
| <a name="input_auto_close"></a> [auto\_close](#input\_auto\_close)                                  | If an alert policy that was active has no data for this long, any open incidents will close. Must be a valid duration (e.g., "300s").                                                                                                                                                                                                                                                                                                                              | `string`                                                                                                                                                               | `"1800s"` |    no    |
| <a name="input_combiner"></a> [combiner](#input\_combiner)                                          | How to combine the results of multiple conditions to determine if an incident should be opened. Valid values: AND, OR, AND\_WITH\_MATCHING\_RESOURCE.                                                                                                                                                                                                                                                                                                              | `string`                                                                                                                                                               | n/a       |   yes    |
| <a name="input_conditions"></a> [conditions](#input\_conditions)                                    | List of conditions to include in the alert policy. Each condition defines how a specific metric should be monitored.<br/>- display\_name – Name of the condition.<br/>- comparison – The comparison to apply between the time series and the threshold (e.g., COMPARISON\_GT).<br/>- threshold\_value – The value against which to compare the metric.<br/>- duration – The length of time that a time series must violate the threshold to be considered failing. | <pre>list(object({<br/>    display_name    = string<br/>    comparison      = string<br/>    threshold_value = number<br/>    duration        = string<br/>  }))</pre> | n/a       |   yes    |
| <a name="input_description"></a> [description](#input\_description)                                 | A description of this metric, which is used in documentation. The maximum length of the description is 8000 characters.                                                                                                                                                                                                                                                                                                                                            | `string`                                                                                                                                                               | `null`    |    no    |
| <a name="input_filter"></a> [filter](#input\_filter)                                                | An advanced logs filter (https://cloud.google.com/logging/docs/view/advanced-filters) which is used to match log entries.                                                                                                                                                                                                                                                                                                                                          | `string`                                                                                                                                                               | n/a       |   yes    |
| <a name="input_metric_kind"></a> [metric\_kind](#input\_metric\_kind)                               | Whether the metric records instantaneous values, changes to a value, etc. Some combinations of metricKind and valueType might not be supported. For counter metrics, set this to DELTA. Possible values are: DELTA, GAUGE, CUMULATIVE.                                                                                                                                                                                                                             | `string`                                                                                                                                                               | n/a       |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                      | The metric identifier.                                                                                                                                                                                                                                                                                                                                                                                                                                             | `string`                                                                                                                                                               | n/a       |   yes    |
| <a name="input_notification_channels"></a> [notification\_channels](#input\_notification\_channels) | Identifiers of the notification channels to use for this alert. Each channel must already exist in the project.                                                                                                                                                                                                                                                                                                                                                    | `list(string)`                                                                                                                                                         | `null`    |    no    |
| <a name="input_resource_type"></a> [resource\_type](#input\_resource\_type)                         | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                | `string`                                                                                                                                                               | `null`    |    no    |
| <a name="input_unit"></a> [unit](#input\_unit)                                                      | The unit in which the metric value is reported. It is only applicable if the valueType is INT64, DOUBLE, or DISTRIBUTION.                                                                                                                                                                                                                                                                                                                                          | `string`                                                                                                                                                               | `null`    |    no    |
| <a name="input_user_labels"></a> [user\_labels](#input\_user\_labels)                               | A set of custom labels for the alert policy. Label keys and values can be used to organize and identify alert policies.                                                                                                                                                                                                                                                                                                                                            | `map(string)`                                                                                                                                                          | `null`    |    no    |
| <a name="input_value_type"></a> [value\_type](#input\_value\_type)                                  | Whether the measurement is an integer, a floating-point number, etc. Some combinations of metricKind and valueType might not be supported. For counter metrics, set this to INT64. Possible values are: BOOL, INT64, DOUBLE, STRING, DISTRIBUTION, MONEY.                                                                                                                                                                                                          | `string`                                                                                                                                                               | n/a       |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
