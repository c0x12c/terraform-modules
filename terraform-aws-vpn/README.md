# AWS Client VPN endpoint Terraform module

This supports 1024-bit and 2048-bit RSA key sizes only.

## Usage

### Create a Client VPN endpoint

```hcl
module "vpn" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/vpn?ref=v0.1.0"

  endpoint_name                  = "example"
  endpoint_client_cidr_block     = "172.16.0.0/20"
  endpoint_subnets               = ["subnet-12345678a"] # private subnet
  endpoint_vpc_id                = "vpc-04b6207e33a2a62cb"
  saml_provider_arn              = "arn:aws:iam::123456788901:saml-provider/aws-client-vpn"
  self_service_saml_provider_arn = "arn:aws:iam::123456788901:saml-provider/aws-client-vpn-self-service"
  certificate_arn                = "arn:aws:acm:us-east-1:123456788901:certificate/abcd1234-ab12-cd34-ef56-abcdef123456"
  additional_routes = [
    {
      subnet_id              = "subnet-12345678a"
      destination_cidr_block = "0.0.0.0/0"
    },
  ]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | \>= 5.75 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls)                   | \>= 4.0  |

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | \>= 5.75 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | \>= 4.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                   | Type        |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate)                                                | resource    |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                      | resource    |
| [aws_cloudwatch_log_stream.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream)                                    | resource    |
| [aws_ec2_client_vpn_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule)            | resource    |
| [aws_ec2_client_vpn_authorization_rule.this_all_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource    |
| [aws_ec2_client_vpn_authorization_rule.this_sso_to_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource    |
| [aws_ec2_client_vpn_endpoint.this_sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint)                            | resource    |
| [aws_ec2_client_vpn_network_association.this_sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association)      | resource    |
| [aws_ec2_client_vpn_route.this_sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route)                                  | resource    |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                                  | resource    |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                                                        | resource    |
| [tls_self_signed_cert.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert)                                              | resource    |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc)                                                                     | data source |

## Inputs

| Name                                                                                                                                                           | Description                                                                                                                                                                                                                                                                                                                                                     | Type                | Default                       | Required |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|-------------------------------|:--------:|
| <a name="input_additional_routes"></a> [additional\_routes](#input\_additional\_routes)                                                                        | A list of maps where each map contains a subnet ID of endpoint subnet for network association and a cidr to where traffic should be routed from that subnet                                                                                                                                                                                                     | `list(map(string))` | `[]`                          |    no    |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules)                                                                  | Map containing authorization rule configuration. rule\_name = "target\_network\_cidr, access\_group\_id"                                                                                                                                                                                                                                                        | `map(string)`       | `{}`                          |    no    |
| <a name="input_authorization_rules_all_groups"></a> [authorization\_rules\_all\_groups](#input\_authorization\_rules\_all\_groups)                             | Map containing authorization rule configuration with authorize\_all\_groups=true. rule\_name = "target\_network\_cidr"                                                                                                                                                                                                                                          | `map(string)`       | `{}`                          |    no    |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn)                                                                              | The ARN of ACM certigicate to use for the VPN server config                                                                                                                                                                                                                                                                                                     | `string`            | `null`                        |    no    |
| <a name="input_cloudwatch_log_group_name_prefix"></a> [cloudwatch\_log\_group\_name\_prefix](#input\_cloudwatch\_log\_group\_name\_prefix)                     | Specifies the name prefix of CloudWatch Log Group for VPC flow logs                                                                                                                                                                                                                                                                                             | `string`            | `"/aws/client-vpn-endpoint/"` |    no    |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group for VPN connection logs                                                                                                                                                                                                                                                   | `number`            | `30`                          |    no    |
| <a name="input_create_endpoint"></a> [create\_endpoint](#input\_create\_endpoint)                                                                              | Create Client VPN Endpoint                                                                                                                                                                                                                                                                                                                                      | `bool`              | `true`                        |    no    |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers)                                                                                          | DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the connecting device is used. Conflict with `use_vpc_internal_dns`                                                                                                                                          | `list(string)`      | `[]`                          |    no    |
| <a name="input_enable_service_portal"></a> [enable\_service\_portal](#input\_enable\_service\_portal)                                                          | Indicates whether service-portal is enabled on VPN endpoint                                                                                                                                                                                                                                                                                                     | `string`            | `"enabled"`                   |    no    |
| <a name="input_enable_split_tunnel"></a> [enable\_split\_tunnel](#input\_enable\_split\_tunnel)                                                                | Indicates whether split-tunnel is enabled on VPN endpoint                                                                                                                                                                                                                                                                                                       | `bool`              | `true`                        |    no    |
| <a name="input_endpoint_client_cidr_block"></a> [endpoint\_client\_cidr\_block](#input\_endpoint\_client\_cidr\_block)                                         | The IPv4 address range, in CIDR notation, from which to assign client IP addresses. The address range cannot overlap with the local CIDR of the VPC in which the associated subnet is located, or the routes that you add manually. The address range cannot be changed after the Client VPN endpoint has been created. The CIDR block should be /22 or greater | `string`            | `"10.100.100.0/24"`           |    no    |
| <a name="input_endpoint_name"></a> [endpoint\_name](#input\_endpoint\_name)                                                                                    | Name to be used on the Client VPN Endpoint                                                                                                                                                                                                                                                                                                                      | `string`            | n/a                           |   yes    |
| <a name="input_endpoint_subnets"></a> [endpoint\_subnets](#input\_endpoint\_subnets)                                                                           | List of IDs of endpoint subnets for network association                                                                                                                                                                                                                                                                                                         | `list(string)`      | n/a                           |   yes    |
| <a name="input_endpoint_vpc_id"></a> [endpoint\_vpc\_id](#input\_endpoint\_vpc\_id)                                                                            | VPC where the VPN will be connected                                                                                                                                                                                                                                                                                                                             | `string`            | n/a                           |   yes    |
| <a name="input_saml_provider_arn"></a> [saml\_provider\_arn](#input\_saml\_provider\_arn)                                                                      | The ARN of the IAM SAML identity provider                                                                                                                                                                                                                                                                                                                       | `string`            | n/a                           |   yes    |
| <a name="input_self_service_saml_provider_arn"></a> [self\_service\_saml\_provider\_arn](#input\_self\_service\_saml\_provider\_arn)                           | The ARN of the IAM Self Service SAML identity provider                                                                                                                                                                                                                                                                                                          | `string`            | n/a                           |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                                                 | A map of tags to add to all resources                                                                                                                                                                                                                                                                                                                           | `map(string)`       | `{}`                          |    no    |
| <a name="input_tls_subject_common_name"></a> [tls\_subject\_common\_name](#input\_tls\_subject\_common\_name)                                                  | The common\_name for subject for which a certificate is being requested. RFC5280. Not used if certificate\_arn provided                                                                                                                                                                                                                                         | `string`            | `"vpn.example.com"`           |    no    |
| <a name="input_tls_validity_period_hours"></a> [tls\_validity\_period\_hours](#input\_tls\_validity\_period\_hours)                                            | Specifies the number of hours after initial issuing that the certificate will become invalid.  Not used if certificate\_arn provided                                                                                                                                                                                                                            | `number`            | `47400`                       |    no    |
| <a name="input_transport_protocol"></a> [transport\_protocol](#input\_transport\_protocol)                                                                     | The transport protocol to be used by the VPN session                                                                                                                                                                                                                                                                                                            | `string`            | `"udp"`                       |    no    |
| <a name="input_use_vpc_internal_dns"></a> [use\_vpc\_internal\_dns](#input\_use\_vpc\_internal\_dns)                                                           | Use VPC Internal DNS as is DNS servers                                                                                                                                                                                                                                                                                                                          | `bool`              | `true`                        |    no    |

## Outputs

| Name                                                                                                                                                  | Description                                      |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------|
| <a name="output_ec2_client_vpn_endpoint_arn"></a> [ec2\_client\_vpn\_endpoint\_arn](#output\_ec2\_client\_vpn\_endpoint\_arn)                         | The ARN of the Client VPN endpoint               |
| <a name="output_ec2_client_vpn_endpoint_id"></a> [ec2\_client\_vpn\_endpoint\_id](#output\_ec2\_client\_vpn\_endpoint\_id)                            | The ID of the Client VPN endpoint                |
| <a name="output_ec2_client_vpn_network_associations"></a> [ec2\_client\_vpn\_network\_associations](#output\_ec2\_client\_vpn\_network\_associations) | Network associations for AWS Client VPN endpoint |
| <a name="output_security_group_description"></a> [security\_group\_description](#output\_security\_group\_description)                                | Security group description                       |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id)                                                           | A map of tags to add to all resources            |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name)                                                     | Name of the security group                       |
| <a name="output_security_group_vpc_id"></a> [security\_group\_vpc\_id](#output\_security\_group\_vpc\_id)                                             | VPC ID                                           |

<!-- END_TF_DOCS -->
