# AWS ECS cluster Terraform module

Terraform module which creates ECS cluster resources on AWS.

This module will create the components:

- A CloudWatch log group for the cluster
- ECS cluster

## Usage

### Create Elasticache

```hcl
module "ecs_cluster" {
  source = "github.com/spartan-stratos/terraform-modules//aws/ecs-cluster?ref=v0.3.0"

  cluster_name = "example"
  tags = {
    Name        = "example"
    Environment = "dev"
  }
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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_service_discovery_http_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_http_namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of ECS cluster | `string` | n/a | yes |
| <a name="input_enabled_service_connect"></a> [enabled\_service\_connect](#input\_enabled\_service\_connect) | Whether to create service connect namespace for service internal discovery. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster"></a> [cluster](#output\_cluster) | The ECS cluster |
| <a name="output_service_connect_namespace_arn"></a> [service\_connect\_namespace\_arn](#output\_service\_connect\_namespace\_arn) | n/a |
| <a name="output_service_connect_namespace_name"></a> [service\_connect\_namespace\_name](#output\_service\_connect\_namespace\_name) | n/a |
<!-- END_TF_DOCS -->