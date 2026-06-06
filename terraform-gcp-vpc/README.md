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
  source = "../../"

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

| Name                                                                                                                                                                             | Type     |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)                                                     | resource |
| [google_compute_global_address.private_ip_peering](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address)                        | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection.html) | resource |
| [google_compute_subnetwork.application](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)                                       | resource |
| [google_compute_subnetwork.data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)                                              | resource |
| [google_compute_address.nat_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)                                                  | resource |
| [google_compute_router.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)                                                      | resource |
| [google_compute_router_nat.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat)                                              | resource |

## Inputs

| Name                                                                              | Description                                                                                   | Type                                                                                                                                                                      | Default  | Required |
|-----------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|:--------:|
| <a name="input_create_new"></a> [create\_new](#input\_create\_new)                | Flag to determine if new resources should be created                                          | `bool`                                                                                                                                                                    | `false`  |    no    |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone)                      | The DNS zone name for Cloud DNS configuration                                                 | `string`                                                                                                                                                                  | n/a      |   yes    |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name)                      | The DNS name for Cloud DNS configuration                                                      | `string`                                                                                                                                                                  | n/a      |   yes    |
| <a name="input_dns_description"></a> [dns\_description](#input\_dns\_description) | The DNS zone description for Cloud DNS configuration                                          | `string`                                                                                                                                                                  | ` `      |    no    |
| <a name="input_dns_visibility"></a> [dns\_visibility](#input\_dns\_visibility)    | The DNS zone visibility for Cloud DNS configuration                                           | `string`                                                                                                                                                                  | `public` |    no    |
| <a name="input_custom_records"></a> [custom\_records](#input\_custom\_records)    | Custom DNS records for Cloud DNS configuration, with options for type, TTL, and record values | <pre>map(object({<br/>    type    = optional(string) // default: CNAME<br/>    ttl     = optional(number) // default: 3600<br/>    rrdatas = list(string)<br/>  }))</pre> | `{}`     |    no    |

## Outputs

| Name                                                                                                                              | Description                                                                       |
|-----------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| <a name="output_application_subnetwork_id"></a> [application\_subnetwork\_id](#output\_application\_subnetwork\_id)               | The ID of the application subnetwork.                                             |
| <a name="output_application_subnetwork_name"></a> [application\_subnetwork\_name](#output\_application\_subnetwork\_name)         | The name of the application subnetwork.                                           |
| <a name="output_data_subnetwork_id"></a> [data\_subnetwork\_id](#output\_data\_subnetwork\_id)                                    | The name of the data subnetwork.                                                  |
| <a name="output_vpc_network_id"></a> [vpc\_network\_id](#output\_vpc\_network\_id)                                                | The ID of the VPC network.                                                        |
| <a name="output_vpc_network_name"></a> [vpc\_network\_name](#output\_vpc\_network\_name)                                          | The name of the VPC network.                                                      |
| <a name="output_services_secondary_range_name"></a> [services\_secondary\_range\_name](#output\_services\_secondary\_range\_name) | The name of the application subnetwork's secondary_ip_range range name: services. |
| <a name="output_pods_secondary_range_name"></a> [pods\_secondary\_range\_name](#output\_pods\_secondary\_range\_name)             | The name of the application subnetwork's secondary_ip_range range name: pods.     |
| <a name="output_cloud_router"></a> [cloud\_router](#output\_cloud\_router)                                                        | A reference (self_link) to the Cloud Router.                                      |
| <a name="output_cloud_nat_id"></a> [cloud\_nat\_id](#output\_cloud\_nat\_id)                                                      | A full resource identifier of the Cloud NAT.                                      |
| <a name="output_google_compute_address"></a> [google\_compute\_address](#output\_google\_compute\_address)                        | A reference (self_link) to the Google Compute Address.                            |

<!-- END_TF_DOCS -->
