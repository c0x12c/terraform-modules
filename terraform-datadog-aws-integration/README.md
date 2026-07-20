# Datadog AWS integration module

Terraform module which creates Datadog AWS integration resources and the required IAM role/policy.

## Usage

```hcl
module "datadog_aws_integration" {
  source  = "terraform.c0x12c.com/c0x12c/aws-integration/datadog"
  version = "1.0.1"

  # Default: null (collect all namespaces). Override to restrict to specific namespaces:
  namespace_filters_include_only = ["AWS/ElastiCache", "AWS/RDS", "AWS/EC2"]

  # To exclude specific namespaces instead (mutually exclusive with include_only):
  # namespace_filters_exclude_only = ["AWS/Billing"]

  # Limit a namespace to resources matching AWS tags (cuts GetMetricData costs):
  metric_tag_filters = [
    { namespace = "AWS/ApplicationELB", tags = ["datadog-metrics:true"] },
  ]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | ~> 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | ~> 4.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datadog_aws_integration_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [datadog_integration_aws_account.sandbox](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_account) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.datadog_aws_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.datadog_aws_integration_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_attached_policy_arns"></a> [aws\_attached\_policy\_arns](#input\_aws\_attached\_policy\_arns) | List of AWS policy ARNs to attach to the Datadog AWS integration IAM role (e.g. arn:aws:iam::aws:policy/SecurityAudit). | `list(string)` | `[]` | no |
| <a name="input_datadog_aws_integration_iam_role"></a> [datadog\_aws\_integration\_iam\_role](#input\_datadog\_aws\_integration\_iam\_role) | Name of the IAM role used for integrating Datadog with AWS. | `string` | `"DatadogAWSIntegrationRole"` | no |
| <a name="input_datadog_permissions"></a> [datadog\_permissions](#input\_datadog\_permissions) | List of AWS IAM permissions required for Datadog integration with AWS services. Reference: https://docs.datadoghq.com/integrations/amazon_web_services/#aws-integration-iam-policy. | `list(string)` | `null` | no |
| <a name="input_extended_collection"></a> [extended\_collection](#input\_extended\_collection) | Enable Datadog's extended resource collection, which allows additional resource tags and configuration information to be collected. Reference: https://docs.datadoghq.com/integrations/amazon_web_services/#resource-collection. | `bool` | `false` | no |
| <a name="input_metric_tag_filters"></a> [metric\_tag\_filters](#input\_metric\_tag\_filters) | Per-namespace AWS resource tag filters limiting metric collection, e.g. [{ namespace = "AWS/ApplicationELB", tags = ["datadog-metrics:true"] }]. Within a listed namespace only resources matching the tags are collected (reduces CloudWatch GetMetricData polling costs); namespaces not listed are unaffected. Reference: https://docs.datadoghq.com/account_management/billing/aws/#aws-resource-exclusion. | <pre>list(object({<br/>    namespace = string<br/>    tags      = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_namespace_filters_exclude_only"></a> [namespace\_filters\_exclude\_only](#input\_namespace\_filters\_exclude\_only) | Exclude these AWS CloudWatch namespaces from metrics collection; all others are collected. Mutually exclusive with namespace\_filters\_include\_only. Ignored when namespace\_filters\_include\_only is set. Reference: https://docs.datadoghq.com/integrations/#cat-aws. | `list(string)` | `null` | no |
| <a name="input_namespace_filters_include_only"></a> [namespace\_filters\_include\_only](#input\_namespace\_filters\_include\_only) | Collect metrics only from these AWS CloudWatch namespaces (e.g. ["AWS/ElastiCache", "AWS/RDS"]). Mutually exclusive with namespace\_filters\_exclude\_only. Reference: https://docs.datadoghq.com/integrations/#cat-aws. | `list(string)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
