# GCP Service Connection Policies Terraform module

This Terraform module allows creation and management of a Service Connection Policy (SCP) in Google Cloud's Network
Connectivity Center.

It defines the policies governing service connections between a Virtual Private Cloud (VPC) and other Google Cloud
services, providing rules on how service connections should be established and configured.

## Usage

### Create GCP Service Connection Policies

```hcl
module "service_connection_policies" {
  source  = "github.com/spartan-stratos/terraform-modules//gcp/service-connection-policies?ref=v0.1.5"
  
  gcp_region = "us-west-1"
  subnet_id  = "<subnet-id>"
  vpc_id     = "<vpc-id>"
  policies = {
    policy1 = {
      description   = "Policy for service A"
      service_class = "service-class-a"
    },
    policy2 = {
      description   = "Policy for service B"
      service_class = "service-class-b"
    }
  }
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | \>= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google)          | \>= 6.12  |

## Providers

| Name                                                       | Version  |
|------------------------------------------------------------|----------|
| <a name="provider_google"></a> [google](#provider\_google) | \>= 6.12 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                        | Type     |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [google_network_connectivity_service_connection_policy.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_connectivity_service_connection_policy) | resource |

## Inputs

| Name                                                               | Description                                                                                                                                       | Type                                                                                            | Default | Required |
|--------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The Google Cloud region where resources will be deployed.                                                                                         | `string`                                                                                        | n/a     |   yes    |
| <a name="input_policies"></a> [policies](#input\_policies)         | A map of service connection policies, each defined by a description and service class.                                                            | <pre>map(object({<br/>    description   = string<br/>    service_class = string<br/>  }))</pre> | `{}`    |    no    |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)    | The ID of the subnet where the service connection will be established with `format projects/{{project}}/regions/{{region}}/subnetworks/{{name}}`. | `string`                                                                                        | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)             | The ID of the VPC network to which the service connection policy applies.                                                                         | `string`                                                                                        | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->