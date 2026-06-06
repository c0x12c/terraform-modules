# AWS Security Groups Terraform module

Terraform module which creates Security Groups resources on AWS.

This module will create the following components:

- AWS Security Groups
- Security Group Rules (Ingress and Egress)

## Usage

### Create Custom Security Groups

```hcl
module "security_groups" {
  source = "github.com/spartan-stratos/terraform-modules//aws/security-group?ref=v0.1.33"
  
  create_default_security_group = false
  security_groups = {
    "example-sg" = {
      name        = "example-sg"
      description = "Example Security Group"
      vpc_id      = "vpc-12345678"
      ingress_rules = {
        "rule1" = {
          protocol    = "-1"
          cidr_ipv4   = "0.0.0.0/0"
          cidr_ipv6   = "::/0"
          description = "Example Rule 1"
        }
        "rule2" = {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          self        = true
          description = "Allow unrestricted traffic within this security group"
        }
      }
      egress_rules = {
        "rule1" = {
          protocol    = "-1"
          cidr_ipv4   = "0.0.0.0/0"
          cidr_ipv6   = "::/0"
          description = "Example Rule 1"
        }
      }
    }
  }
}
```

### Create Default Security Groups

```hcl
module "security_groups" {
  source = "github.com/spartan-stratos/terraform-modules//aws/security-group?ref=v0.1.23"

  create_default_security_group = true
  vpc_id                        = "vpc-12345678"
  cidr_blocks                   = ["10.0.0.0/16"]
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
| [aws_security_group.allow_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.allow_all_within_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_security_group_egress_rule.egress_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.egress_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ingress_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ingress_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | List of allowed CIDR blocks used to define ingress/egress rules for the security groups. | `list(string)` | `[]` | no |
| <a name="input_create_default_security_group"></a> [create\_default\_security\_group](#input\_create\_default\_security\_group) | Flag to determine whether a default security group should be created. | `bool` | `true` | no |
| <a name="input_custom_sg_allow_all_description"></a> [custom\_sg\_allow\_all\_description](#input\_custom\_sg\_allow\_all\_description) | Custom description for security group allow all `aws_security_group.allow_all`. | `string` | `null` | no |
| <a name="input_custom_sg_allow_all_within_vpc_description"></a> [custom\_sg\_allow\_all\_within\_vpc\_description](#input\_custom\_sg\_allow\_all\_within\_vpc\_description) | Custom description for security group allow all within vpc `aws_security_group.allow_all_within_vpc`. | `string` | `null` | no |
| <a name="input_custom_sg_allow_all_within_vpc_egress_ipv6_cidr_blocks"></a> [custom\_sg\_allow\_all\_within\_vpc\_egress\_ipv6\_cidr\_blocks](#input\_custom\_sg\_allow\_all\_within\_vpc\_egress\_ipv6\_cidr\_blocks) | Custom IPv6 CIDR blocks to allow in the egress rules for the security group allow\_all\_within\_vpc | `list(string)` | <pre>[<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_ipv6_cidr_blocks"></a> [ipv6\_cidr\_blocks](#input\_ipv6\_cidr\_blocks) | List of allowed IPv6 CIDR blocks used to define ingress/egress rules for the security groups. | `list(string)` | `[]` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A map of security groups with their associated ingress and egress rules, to be applied to a VPC. | <pre>map(object({<br/>    name        = string<br/>    description = string<br/>    vpc_id      = string<br/>    ingress_rules = optional(map(object({<br/>      from_port   = optional(number, null) # Port range start for ingress traffic, null means not specified<br/>      to_port     = optional(number, null) # Port range end for ingress traffic, null means not specified<br/>      protocol    = optional(string, null) # Protocol for ingress traffic (e.g., 'tcp', 'udp', etc.), null means not specified<br/>      cidr_ipv4   = optional(string, null) # IPv4 CIDR block for ingress traffic, null means not specified<br/>      cidr_ipv6   = optional(string, null) # IPv6 CIDR block for ingress traffic, null means not specified<br/>      description = optional(string, null) # Description of the ingress rule, null means not specified<br/>      self        = optional(bool, false)  # Whether to allow traffic from the security group itself, defaults to false<br/>    })), null)                             # A map of ingress rules for the security group, can be null if no ingress rules are specified<br/>    egress_rules = optional(map(object({<br/>      from_port   = optional(number, null) # Port range start for egress traffic, null means not specified<br/>      to_port     = optional(number, null) # Port range end for egress traffic, null means not specified<br/>      protocol    = optional(string, null) # Protocol for egress traffic (e.g., 'tcp', 'udp', etc.), null means not specified<br/>      cidr_ipv4   = optional(string, null) # IPv4 CIDR block for egress traffic, null means not specified<br/>      cidr_ipv6   = optional(string, null) # IPv6 CIDR block for egress traffic, null means not specified<br/>      description = optional(string, null) # Description of the egress rule, null means not specified<br/>      self        = optional(bool, false)  # Whether to allow traffic to the security group itself, defaults to false<br/>    })), null)<br/>    tags = optional(map(string), {}) # A map of egress rules for the security group, can be null if no egress rules are specified<br/>  }))</pre> | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the main VPC associated with the security groups. Can be null if not provided. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_allow_all_id"></a> [security\_group\_allow\_all\_id](#output\_security\_group\_allow\_all\_id) | The ID of the 'allow all' security group. |
| <a name="output_security_group_allow_all_within_vpc_id"></a> [security\_group\_allow\_all\_within\_vpc\_id](#output\_security\_group\_allow\_all\_within\_vpc\_id) | The ID of the 'allow all within VPC' security group. |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Map of security group names to their IDs |
<!-- END_TF_DOCS -->
