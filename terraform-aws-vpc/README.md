# AWS VPC Terraform module

Terraform module which creates VPC resources on AWS.

This module will create the following components:

- A VPC
- An Internet Gateway attached to the VPC
- Public and private subnets, along with the public and private route tables
- A NAT Gateways (with n equals the number of private subnets), you can specify `enable_single_nat=true` to use only 1
  NAT gateway for all private subnets
- An EIP (with n equals the number of NAT gateways) attached to the NAT gateways

The traffic in private route tables will transfer through the NAT gateway to go inside, they will share the same EIP (
for traffic in one AZ)

You can specify `enable_single_nat=true` to enable only one NAT gateway for all the private subnets, this would help
achieve decreasing cost and centralized all the traffic in private subnets under 1 public IP

## Usage

### Create a VPC

```hcl
module "vpc" {
  source = "github.com/spartan-stratos/terraform-modules//aws/vpc?ref=v0.1.69"

  name                        = "example"
  cidr_block                  = "10.0.1.0/16"
  availability_zone_postfixes = ["a", "b", "c"]
  environment                 = "dev"
  single_nat                  = true
  region                      = "us-west-2"
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

| Name                                                                                                                                       | Type     |
|--------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)          | resource |
| [aws_db_subnet_group.private_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group)        | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                             | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log)                                  | resource |
| [aws_iam_role.vpc-flow-logs-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                    | resource |
| [aws_iam_role_policy.vpc-flow-logs-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)    | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                  | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                            | resource |
| [aws_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)                            | resource |
| [aws_network_acl_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)                  | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                     | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                      | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                         | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                          | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)  | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                   | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                    | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                            | resource |

## Inputs

| Name                                                                                                                                                   | Description                                          | Type                                                                                                                                                                                                                                                                                                                                                                                  | Default | Required |
|--------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_availability_zone_postfixes"></a> [availability\_zone\_postfixes](#input\_availability\_zone\_postfixes)                                | List of availability zones                           | `list(string)`                                                                                                                                                                                                                                                                                                                                                                        | n/a     |   yes    |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block)                                                                                     | The CIDR block for the VPC.                          | `string`                                                                                                                                                                                                                                                                                                                                                                              | n/a     |   yes    |
| <a name="input_cluster_names"></a> [cluster\_names](#input\_cluster\_names)                                                                            | List of EKS cluster names within with VPC            | `list(string)`                                                                                                                                                                                                                                                                                                                                                                        | `[]`    |    no    |
| <a name="input_create_custom_subnets"></a> [create\_custom\_subnets](#input\_create\_custom\_subnets)                                                  | Whether to create custom subnets.                    | `bool`                                                                                                                                                                                                                                                                                                                                                                                | `false` |    no    |
| <a name="input_create_flow_log"></a> [create\_flow\_log](#input\_create\_flow\_log)                                                                    | Whether to create VPC flow logs.                     | `bool`                                                                                                                                                                                                                                                                                                                                                                                | `false` |    no    |
| <a name="input_create_private_database_subnet_group"></a> [create\_private\_database\_subnet\_group](#input\_create\_private\_database\_subnet\_group) | Whether to create private database subnet group      | `bool`                                                                                                                                                                                                                                                                                                                                                                                | `false` |    no    |
| <a name="input_created_managed_node_group"></a> [created\_managed\_node\_group](#input\_created\_managed\_node\_group)                                 | Whether Managed Node Groups are created in this VPC  | `bool`                                                                                                                                                                                                                                                                                                                                                                                | `false` |    no    |
| <a name="input_custom_acls"></a> [custom\_acls](#input\_custom\_acls)                                                                                  | List of custom ACLs that overrides AWS default ACLs. | <pre>map(object({<br/>    rule_number = number<br/>    cidr_block  = string<br/>    protocol    = string<br/>    rule_action = string<br/>    egress      = optional(bool, false)<br/>    from_port   = optional(number, null)<br/>    to_port     = optional(number, null)<br/>    icmp_type   = optional(string, null)<br/>    icmp_code   = optional(string, null)<br/>  }))</pre> | `null`  |    no    |
| <a name="input_custom_private_subnets"></a> [custom\_private\_subnets](#input\_custom\_private\_subnets)                                               | List of custom private subnets.                      | `list(string)`                                                                                                                                                                                                                                                                                                                                                                        | `[]`    |    no    |
| <a name="input_custom_public_subnets"></a> [custom\_public\_subnets](#input\_custom\_public\_subnets)                                                  | List of custom public subnets.                       | `list(string)`                                                                                                                                                                                                                                                                                                                                                                        | `[]`    |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                         | The name of your VPC                                 | `string`                                                                                                                                                                                                                                                                                                                                                                              | n/a     |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                                                                   | The region of the VPC                                | `string`                                                                                                                                                                                                                                                                                                                                                                              | n/a     |   yes    |
| <a name="input_single_nat"></a> [single\_nat](#input\_single\_nat)                                                                                     | Whether to create a single NAT gateway or one per AZ | `bool`                                                                                                                                                                                                                                                                                                                                                                                | `false` |    no    |

## Outputs

| Name                                                                                                            | Description                       |
|-----------------------------------------------------------------------------------------------------------------|-----------------------------------|
| <a name="output_eip_nat_public_ip"></a> [eip\_nat\_public\_ip](#output\_eip\_nat\_public\_ip)                   | The public IP of internet gateway |
| <a name="output_id"></a> [id](#output\_id)                                                                      | The VPC ID                        |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of private route table IDs   |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id)       | The public route table ID         |
| <a name="output_subnet_private"></a> [subnet\_private](#output\_subnet\_private)                                | The private subnet information    |
| <a name="output_subnet_public"></a> [subnet\_public](#output\_subnet\_public)                                   | The public subnet information     |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block)                              | The VPC CIDR block                |

<!-- END_TF_DOCS -->
