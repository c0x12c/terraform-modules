# AWS VPC Endpoints Terraform module

Terraform module which creates VPC endpoint resources on AWS.

## Usage

### Create a Client VPN endpoint

```hcl
module "vpc_endpoints" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/vpn-endpoints?ref=v0.1.29"

  vpc_id             = "vpc-123456"
  route_table_ids    = ["route_table_1"]
  security_group_ids = ["security_group_1"]
  subnet_ids         = ["subnet_1"]

  enable_s3  = true
  enable_sqs = true
  enable_ecr = true
  enable_eks = true
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                                    | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_vpc_endpoint.ecr_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                    | resource    |
| [aws_vpc_endpoint.ecr_dkr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                    | resource    |
| [aws_vpc_endpoint.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                        | resource    |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                         | resource    |
| [aws_vpc_endpoint.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                        | resource    |
| [aws_vpc_endpoint_service.ecr_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ecr_dkr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service)     | data source |
| [aws_vpc_endpoint_service.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service)      | data source |
| [aws_vpc_endpoint_service.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service)     | data source |

## Inputs

| Name                                                                                         | Description                                                                                                               | Type           | Default | Required |
|----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_enable_ecr"></a> [enable\_ecr](#input\_enable\_ecr)                           | Enable vpc endpoint for ECR service                                                                                       | `bool`         | `false` |    no    |
| <a name="input_enable_eks"></a> [enable\_eks](#input\_enable\_eks)                           | Enable vpc endpoint for EKS service                                                                                       | `bool`         | `false` |    no    |
| <a name="input_enable_s3"></a> [enable\_s3](#input\_enable\_s3)                              | Enable vpc endpoint for S3 service                                                                                        | `bool`         | `false` |    no    |
| <a name="input_enable_sqs"></a> [enable\_sqs](#input\_enable\_sqs)                           | Enable vpc endpoint for SQS service                                                                                       | `bool`         | `false` |    no    |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids)          | One or more route table IDs. Applicable for endpoints of type Gateway                                                     | `list(string)` | n/a     |   yes    |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface. Applicable for endpoints of type Interface | `list(string)` | n/a     |   yes    |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)                           | The ID of one or more subnets in which to create a network interface for the endpoint                                     | `list(string)` | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                       | The ID of the VPC in which the endpoint will be used.                                                                     | `string`       | n/a     |   yes    |

## Outputs

| Name                                                            | Description                                                                        |
|-----------------------------------------------------------------|------------------------------------------------------------------------------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | Array containing the full resource object and attributes for all endpoints created |

<!-- END_TF_DOCS -->