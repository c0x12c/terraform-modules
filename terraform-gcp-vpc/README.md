# Terraform Google Cloud VPC Module

This Terraform module creates a Virtual Private Cloud (VPC) network along with application, data subnetworks, and NAT in
Google Cloud. The module is designed to be reusable and configurable with various options for CIDR blocks, flow logs,
and Google API access.

This module will create the following components:

- Creates a VPC network with a global routing mode.
- Sets up an application subnetwork with secondary IP ranges for services and pods.
- Creates a separate subnetwork for data storage and processing.
- Enables private Google API access within the subnetworks.
- Create NAT.

## Usage

### Create VPC

```hcl
module "vpc" {
  source  = "terraform.c0x12c.com/c0x12c/vpc/gcp"
  version = "0.1.4"

  vpc_name                = "example-vpc"
  region                  = "us-west1"
  application_subnet_cidr = "10.10.0.0/20"
  services_subnet_cidr    = "10.10.16.0/24"
  pods_subnet_cidr        = "10.10.32.0/20"
  data_subnet_cidr        = "10.20.10.0/24"

  nat_ip_address_name = "example-nat"
  router_name         = "example-router"
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.nat_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_global_address.private_ip_peering](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.application](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_subnet_cidr"></a> [application\_subnet\_cidr](#input\_application\_subnet\_cidr) | CIDR block for the application subnet | `string` | `"10.10.0.0/20"` | no |
| <a name="input_data_subnet_cidr"></a> [data\_subnet\_cidr](#input\_data\_subnet\_cidr) | CIDR block for the data subnet | `string` | `"10.20.10.0/24"` | no |
| <a name="input_enable_endpoint_independent_mapping"></a> [enable\_endpoint\_independent\_mapping](#input\_enable\_endpoint\_independent\_mapping) | Specifies if endpoint independent mapping is enabled. | `bool` | `null` | no |
| <a name="input_icmp_idle_timeout_sec"></a> [icmp\_idle\_timeout\_sec](#input\_icmp\_idle\_timeout\_sec) | Timeout (in seconds) for ICMP connections. Defaults to 30s if not set. Changing this forces a new NAT to be created. | `string` | `"30"` | no |
| <a name="input_log_config_enable"></a> [log\_config\_enable](#input\_log\_config\_enable) | Indicates whether or not to export logs | `bool` | `false` | no |
| <a name="input_log_config_filter"></a> [log\_config\_filter](#input\_log\_config\_filter) | Specifies the desired filtering of logs on this NAT. Valid values are: 'ERRORS\_ONLY', 'TRANSLATIONS\_ONLY', 'ALL' | `string` | `"ALL"` | no |
| <a name="input_min_ports_per_vm"></a> [min\_ports\_per\_vm](#input\_min\_ports\_per\_vm) | Minimum number of ports allocated to a VM from this NAT config. Defaults to 64 if not set. Changing this forces a new NAT to be created. | `string` | `"64"` | no |
| <a name="input_nat_ip_address_name"></a> [nat\_ip\_address\_name](#input\_nat\_ip\_address\_name) | Defaults to 'cloud-nat-RANDOM\_SUFFIX'. Changing this forces a new NAT to be created. | `string` | n/a | yes |
| <a name="input_nat_ip_allocate_option"></a> [nat\_ip\_allocate\_option](#input\_nat\_ip\_allocate\_option) | Value inferred based on nat\_ips. If present set to MANUAL\_ONLY, otherwise AUTO\_ONLY. | `string` | `"MANUAL_ONLY"` | no |
| <a name="input_pods_subnet_cidr"></a> [pods\_subnet\_cidr](#input\_pods\_subnet\_cidr) | CIDR block for the pods secondary IP range | `string` | `"10.10.32.0/20"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the VPC and subnets will be created | `string` | n/a | yes |
| <a name="input_router_asn"></a> [router\_asn](#input\_router\_asn) | Router ASN, only if router is not passed in and is created by the module. | `string` | `"64514"` | no |
| <a name="input_router_keepalive_interval"></a> [router\_keepalive\_interval](#input\_router\_keepalive\_interval) | Router keepalive\_interval, only if router is not passed in and is created by the module. | `string` | `"20"` | no |
| <a name="input_router_name"></a> [router\_name](#input\_router\_name) | The name of the router in which this NAT will be configured. Changing this forces a new NAT to be created. | `string` | n/a | yes |
| <a name="input_services_subnet_cidr"></a> [services\_subnet\_cidr](#input\_services\_subnet\_cidr) | CIDR block for the services secondary IP range | `string` | `"10.10.16.0/24"` | no |
| <a name="input_source_subnetwork_ip_ranges_to_nat"></a> [source\_subnetwork\_ip\_ranges\_to\_nat](#input\_source\_subnetwork\_ip\_ranges\_to\_nat) | Defaults to ALL\_SUBNETWORKS\_ALL\_IP\_RANGES. How NAT should be configured per Subnetwork. Valid values include: ALL\_SUBNETWORKS\_ALL\_IP\_RANGES, ALL\_SUBNETWORKS\_ALL\_PRIMARY\_IP\_RANGES, LIST\_OF\_SUBNETWORKS. Changing this forces a new NAT to be created. | `string` | `"LIST_OF_SUBNETWORKS"` | no |
| <a name="input_subnetworks"></a> [subnetworks](#input\_subnetworks) | Specifies one or more subnetwork NAT configurations | <pre>list(object({<br/>    name                    = string,<br/>    source_ip_ranges_to_nat = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_tcp_established_idle_timeout_sec"></a> [tcp\_established\_idle\_timeout\_sec](#input\_tcp\_established\_idle\_timeout\_sec) | Timeout (in seconds) for TCP established connections. Defaults to 1200s if not set. Changing this forces a new NAT to be created. | `string` | `"1200"` | no |
| <a name="input_tcp_transitory_idle_timeout_sec"></a> [tcp\_transitory\_idle\_timeout\_sec](#input\_tcp\_transitory\_idle\_timeout\_sec) | Timeout (in seconds) for TCP transitory connections. Defaults to 30s if not set. Changing this forces a new NAT to be created. | `string` | `"30"` | no |
| <a name="input_udp_idle_timeout_sec"></a> [udp\_idle\_timeout\_sec](#input\_udp\_idle\_timeout\_sec) | Timeout (in seconds) for UDP connections. Defaults to 30s if not set. Changing this forces a new NAT to be created. | `string` | `"30"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_subnetwork_id"></a> [application\_subnetwork\_id](#output\_application\_subnetwork\_id) | The ID of the application subnetwork. |
| <a name="output_application_subnetwork_name"></a> [application\_subnetwork\_name](#output\_application\_subnetwork\_name) | The name of the application subnetwork. |
| <a name="output_cloud_nat_id"></a> [cloud\_nat\_id](#output\_cloud\_nat\_id) | A full resource identifier of the Cloud NAT. |
| <a name="output_cloud_router"></a> [cloud\_router](#output\_cloud\_router) | A reference (self\_link) to the Cloud Router. |
| <a name="output_data_subnetwork_id"></a> [data\_subnetwork\_id](#output\_data\_subnetwork\_id) | The ID of the data subnetwork. |
| <a name="output_data_subnetwork_name"></a> [data\_subnetwork\_name](#output\_data\_subnetwork\_name) | The name of the data subnetwork. |
| <a name="output_google_compute_address"></a> [google\_compute\_address](#output\_google\_compute\_address) | A reference (self\_link) to the Google Compute Address. |
| <a name="output_pods_secondary_range_name"></a> [pods\_secondary\_range\_name](#output\_pods\_secondary\_range\_name) | The name of the application subnetwork's secondary\_ip\_range range name: pods. |
| <a name="output_services_secondary_range_name"></a> [services\_secondary\_range\_name](#output\_services\_secondary\_range\_name) | The name of the application subnetwork's secondary\_ip\_range range name: services. |
| <a name="output_vpc_network_id"></a> [vpc\_network\_id](#output\_vpc\_network\_id) | The ID of the VPC network. |
| <a name="output_vpc_network_name"></a> [vpc\_network\_name](#output\_vpc\_network\_name) | The name of the VPC network. |
<!-- END_TF_DOCS -->
