# AWS OpenVPN Terraform module

Terraform module which creates OpenVPN to access internal VPC network.

## Usage

### Create an OpenVPN instance

```hcl
module "openvpn" {
  source = "github.com/spartan-stratos/terraform-modules//aws/openvpn?ref=v0.1.62"

  vpn_name    = "openvpn"
  domain_name = "example.com"

  vpc_id    = "vpc-123456789"
  subnet_id = "subnet-123456789"
  extra_sg_ids = ["sg-123456789"]
  dns_server_cidrs = ["10.0.0.0/16", "172.16.0.0/16"] # resolves to .2 IP in each CIDR

  oauth2_client_id     = "google_client_id"
  oauth2_client_secret = "google_client_secret"
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
| <a name="requirement_random"></a> [random](#requirement\_random)          | >= 3.6.3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls)                   | >= 4.0.6 |

## Providers

| Name                                                       | Version  |
|------------------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)          | >= 5.75  |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls)          | >= 4.0.6 |

## Modules

No modules.

## Resources

| Name                                                                                                                                       | Type        |
|--------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                            | resource    |
| [aws_instance.replacable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                            | resource    |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                                  | resource    |
| [aws_key_pair.management_ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)                    | resource    |
| [aws_route53_record.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                       | resource    |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                      | resource    |
| [aws_security_group_rule.default_ssh_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource    |
| [aws_security_group_rule.egress_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)      | resource    |
| [aws_security_group_rule.http_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)        | resource    |
| [aws_security_group_rule.https_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)       | resource    |
| [aws_security_group_rule.udp_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)         | resource    |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                            | resource    |
| [tls_cert_request.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request)                        | resource    |
| [tls_locally_signed_cert.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert)          | resource    |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                              | resource    |
| [tls_private_key.management_ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)              | resource    |
| [tls_private_key.server](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                          | resource    |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert)                    | resource    |
| [aws_ami.debian](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)                                       | data source |
| [aws_route53_zone.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)                     | data source |

## Inputs

| Name                                                                                                                         | Description                                                                                                          | Type           | Default                               | Required |
|------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|----------------|---------------------------------------|:--------:|
| <a name="input_allow_remote_ssh_access"></a> [allow\_remote\_ssh\_access](#input\_allow\_remote\_ssh\_access)                | Whether to enable the SSH security group rule to allow remote access.                                                | `bool`         | `false`                               |    no    |
| <a name="input_create_egress_vpn_rule"></a> [create\_egress\_vpn\_rule](#input\_create\_egress\_vpn\_rule)                   | Whether to create an egress rule for the VPN.                                                                        | `bool`         | `true`                                |    no    |
| <a name="input_create_management_key_pair"></a> [create\_management\_key\_pair](#input\_create\_management\_key\_pair)       | Whether to create a management key pair.                                                                             | `bool`         | `true`                                |    no    |
| <a name="input_custom_cert_dns_names"></a> [custom\_cert\_dns\_names](#input\_custom\_cert\_dns\_names)                      | A list of custom DNS names to add to the certificate.                                                                | `list(string)` | `null`                                |    no    |
| <a name="input_disk_boot_size"></a> [disk\_boot\_size](#input\_disk\_boot\_size)                                             | The size of the boot disk in GB.                                                                                     | `number`       | `"10"`                                |    no    |
| <a name="input_dns_server_cidrs"></a> [dns\_server\_cidrs](#input\_dns\_server\_cidrs)                                        | A list of CIDRs where the DNS server IP is calculated as host index 2 of each CIDR.                                 | `list(string)` | `[]`                                  |    no    |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name)                                                        | The domain name.                                                                                                     | `string`       | n/a                                   |   yes    |
| <a name="input_ec2_public_key"></a> [ec2\_public\_key](#input\_ec2\_public\_key)                                             | The existing value of ec2 public key. If not set, create and use `tls_private_key`.                                  | `string`       | `null`                                |    no    |
| <a name="input_enabled_http_port"></a> [enabled\_http\_port](#input\_enabled\_http\_port)                                    | Whether to enable HTTP port through security group.                                                                  | `bool`         | `true`                                |    no    |
| <a name="input_extra_sg_ids"></a> [extra\_sg\_ids](#input\_extra\_sg\_ids)                                                   | A list of additional security group IDs.                                                                             | `list(string)` | `[]`                                  |    no    |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint)                                                  | The configuration for enabling or disabling the instance metadata service endpoint.                                  | `string`       | `"enabled"`                           |    no    |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens)                                                        | The configuration for the instance metadata service tokens.                                                          | `string`       | `"optional"`                          |    no    |
| <a name="input_image_distro"></a> [image\_distro](#input\_image\_distro)                                                     | The distribution of the image.                                                                                       | `string`       | `"debian-12-amd64"`                   |    no    |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version)                                                  | The version of the image.                                                                                            | `string`       | `"20240717-1811"`                     |    no    |
| <a name="input_init_script_callback_comment"></a> [init\_script\_callback\_comment](#input\_init\_script\_callback\_comment) | The callback name for the OpenVPN server                                                                             | `string`       | `"Google Oauth 2.0 callback"`         |    no    |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)                                                  | The type of the instance.                                                                                            | `string`       | `"t3.micro"`                          |    no    |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name)                                                                 | The name of the key. If not set, the value of the key will default to the variable vpn\_name.                        | `string`       | `null`                                |    no    |
| <a name="input_oauth2_client_id"></a> [oauth2\_client\_id](#input\_oauth2\_client\_id)                                       | The OAuth2 client ID.                                                                                                | `string`       | n/a                                   |   yes    |
| <a name="input_oauth2_client_secret"></a> [oauth2\_client\_secret](#input\_oauth2\_client\_secret)                           | The OAuth2 client secret.                                                                                            | `string`       | n/a                                   |   yes    |
| <a name="input_oauth2_issuer"></a> [oauth2\_issuer](#input\_oauth2\_issuer)                                                  | The OAuth2 issuer.                                                                                                   | `string`       | `"https://accounts.google.com"`       |    no    |
| <a name="input_oauth2_provider"></a> [oauth2\_provider](#input\_oauth2\_provider)                                            | The OAuth2 provider.                                                                                                 | `string`       | `"google"`                            |    no    |
| <a name="input_oauth2_validate_groups"></a> [oauth2\_validate\_groups](#input\_oauth2\_validate\_groups)                     | The OAuth2 groups to validate, separated by comma                                                                    | `string`       | `null`                                |    no    |
| <a name="input_oauth2_validate_roles"></a> [oauth2\_validate\_roles](#input\_oauth2\_validate\_roles)                        | The OAuth2 roles to validate, separated by comma. For GitHub provider, please note that team names must be slugified | `string`       | `null`                                |    no    |
| <a name="input_openvpn_auth_oauth2_version"></a> [openvpn\_auth\_oauth2\_version](#input\_openvpn\_auth\_oauth2\_version)    | The version of OpenVPN OAuth2 authentication plugin.                                                                 | `string`       | `"1.22.4"`                            |    no    |
| <a name="input_openvpn_fqdn"></a> [openvpn\_fqdn](#input\_openvpn\_fqdn)                                                     | The fully qualified domain name of the OpenVPN.                                                                      | `string`       | `""`                                  |    no    |
| <a name="input_openvpn_ip_pool"></a> [openvpn\_ip\_pool](#input\_openvpn\_ip\_pool)                                          | The IP pool for OpenVPN clients.                                                                                     | `string`       | `"10.8.0.0"`                          |    no    |
| <a name="input_organization"></a> [organization](#input\_organization)                                                       | The name of the organization.                                                                                        | `string`       | `"Spartan"`                           |    no    |
| <a name="input_replace_instance_on_update"></a> [replace\_instance\_on\_update](#input\_replace\_instance\_on\_update)       | Whether to replace the instance on update variables                                                                  | `bool`         | `false`                               |    no    |
| <a name="input_route_network_cidrs"></a> [route\_network\_cidrs](#input\_route\_network\_cidrs)                              | A list of network CIDRs to route.                                                                                    | `list(string)` | <pre>[<br/>  "10.0.0.0/8"<br/>]</pre> |    no    |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)                                                              | The ID of the subnet.                                                                                                | `string`       | n/a                                   |   yes    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                                       | The ID of the VPC.                                                                                                   | `string`       | n/a                                   |   yes    |
| <a name="input_vpn_name"></a> [vpn\_name](#input\_vpn\_name)                                                                 | The name of the VPN.                                                                                                 | `string`       | `"openvpn"`                           |    no    |

## Outputs

| Name                                                                                  | Description                                      |
|---------------------------------------------------------------------------------------|--------------------------------------------------|
| <a name="output_ca_cert"></a> [ca\_cert](#output\_ca\_cert)                           | The OpenVPN CA certificate.                      |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id)               | The ID of the AWS instance.                      |
| <a name="output_instant_arn"></a> [instant\_arn](#output\_instant\_arn)               | The ARN of the AWS instance.                     |
| <a name="output_ovpn_file"></a> [ovpn\_file](#output\_ovpn\_file)                     | n/a                                              |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip)                     | The public IP address of the OpenVPN instance.   |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | The private key for the management SSH key pair. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key)    | The public key for the management SSH key pair.  |

<!-- END_TF_DOCS -->
