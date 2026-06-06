# GCP OpenVPN Terraform module

Terraform module which creates OpenVPN to access internal VPC network.

## Usage

### Create GCP OpenVPN

```hcl
module "openvpn" {
  source  = "github.com/spartan-stratos/terraform-modules//gcp/openvpn?ref=v0.1.5"

  vpn_name    = "openvpn-example"
  domain_name = "example.com"

  vpc_name   = "vpc-name"
  vpc_subnet = "vpc-subnet"

  oauth2_client_id     = "id"
  oauth2_client_secret = "secret"
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google)          | \>= 6.12 |

## Providers

| Name                                                       | Version  |
|------------------------------------------------------------|----------|
| <a name="provider_google"></a> [google](#provider\_google) | \>= 6.12 |

## Modules

No modules.

## Resources

| Name                                                                                                                                   | Type     |
|----------------------------------------------------------------------------------------------------------------------------------------|----------|
| [random_password.management_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)         | resource |
| [tls_private_key.management_ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)          | resource |
| [google_compute_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)          | resource |
| [random_password.management_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)             | resource |

## Inputs

| Name                                                                                                                      | Description                                          | Type           | Default                               | Required |
|---------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------|----------------|---------------------------------------|:--------:|
| <a name="input_disk_boot_size"></a> [disk\_boot\_size](#input\_disk\_boot\_size)                                          | The size of the boot disk in GB.                     | `number`       | `"10"`                                |    no    |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name)                                                     | The domain name.                                     | `string`       | n/a                                   |   yes    |
| <a name="input_image_distro"></a> [image\_distro](#input\_image\_distro)                                                  | The distribution of the image.                       | `string`       | `"debian-12-amd64"`                   |    no    |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version)                                               | The version of the image.                            | `string`       | `"20240717-1811"`                     |    no    |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)                                               | The type of the instance.                            | `string`       | `"t3.micro"`                          |    no    |
| <a name="input_oauth2_client_id"></a> [oauth2\_client\_id](#input\_oauth2\_client\_id)                                    | The OAuth2 client ID.                                | `string`       | n/a                                   |   yes    |
| <a name="input_oauth2_client_secret"></a> [oauth2\_client\_secret](#input\_oauth2\_client\_secret)                        | The OAuth2 client secret.                            | `string`       | n/a                                   |   yes    |
| <a name="input_openvpn_auth_oauth2_version"></a> [openvpn\_auth\_oauth2\_version](#input\_openvpn\_auth\_oauth2\_version) | The version of OpenVPN OAuth2 authentication plugin. | `string`       | `"1.22.4"`                            |    no    |
| <a name="input_openvpn_fqdn"></a> [openvpn\_fqdn](#input\_openvpn\_fqdn)                                                  | The fully qualified domain name of the OpenVPN.      | `string`       | `""`                                  |    no    |
| <a name="input_openvpn_ip_pool"></a> [openvpn\_ip\_pool](#input\_openvpn\_ip\_pool)                                       | The IP pool for OpenVPN clients.                     | `string`       | `"10.8.0.0"`                          |    no    |
| <a name="input_organization"></a> [organization](#input\_organization)                                                    | The name of the organization.                        | `string`       | `"Spartan"`                           |    no    |
| <a name="input_route_network_cidrs"></a> [route\_network\_cidrs](#input\_route\_network\_cidrs)                           | A list of network CIDRs to route.                    | `list(string)` | <pre>[<br/>  "10.0.0.0/8"<br/>]</pre> |    no    |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)                                                           | The ID of the subnet.                                | `string`       | n/a                                   |   yes    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                                    | The ID of the VPC.                                   | `string`       | n/a                                   |   yes    |
| <a name="input_vpn_name"></a> [vpn\_name](#input\_vpn\_name)                                                              | The name of the VPN.                                 | `string`       | `"openvpn"`                           |    no    |

## Outputs

| Name                                                                                  | Description |
|---------------------------------------------------------------------------------------|-------------|
| <a name="output_ovpn_file"></a> [ovpn\_file](#output\_ovpn\_file)                     | n/a         |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip)                     | n/a         |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | n/a         |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key)    | n/a         |

<!-- END_TF_DOCS -->
