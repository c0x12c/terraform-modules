# AWS OpenSearch Terraform module

Terraform module which creates OpenSearch resources on AWS.

## Usage

### Create an OpenSearch cluster

```hcl
module "opensearch" {
  source = "github.com/spartan-stratos/terraform-modules//aws/opensearch?ref=v0.3.16"

  domain             = "opensearch"
  instance_size      = "t3.small.search"
  engine_version     = "OpenSearch_2.13"
  instance_count     = 1
  ebs_enabled        = true
  security_group_ids = ["security_group_1"]
  subnet_ids         = ["subnet_id_1"]
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

| Name                                                                                                                                          | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_service_linked_role.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource    |
| [aws_opensearch_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain)                   | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                 | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                   | data source |

## Inputs

| Name                                                                                                          | Description                                                                                                                                                                                                                                                                                         | Type           | Default                            | Required |
|---------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|------------------------------------|:--------:|
| <a name="input_availability_zone_count"></a> [availability\_zone\_count](#input\_availability\_zone\_count)   | Number of availability zones to enable from 2-3.                                                                                                                                                                                                                                                    | `number`       | `3`                                |    no    |
| <a name="input_create_linked_role"></a> [create\_linked\_role](#input\_create\_linked\_role)                  | Create a service linked role for Amazon OpenSearch Service to access VPC resources                                                                                                                                                                                                                  | `bool`         | `false`                            |    no    |
| <a name="input_domain"></a> [domain](#input\_domain)                                                          | The domain for creating open search                                                                                                                                                                                                                                                                 | `string`       | n/a                                |   yes    |
| <a name="input_ebs_enabled"></a> [ebs\_enabled](#input\_ebs\_enabled)                                         | Enable EBS                                                                                                                                                                                                                                                                                          | `bool`         | `false`                            |    no    |
| <a name="input_ebs_storage_size"></a> [ebs\_storage\_size](#input\_ebs\_storage\_size)                        | Enable EBS                                                                                                                                                                                                                                                                                          | `number`       | `10`                               |    no    |
| <a name="input_encrypt_at_rest_enabled"></a> [encrypt\_at\_rest\_enabled](#input\_encrypt\_at\_rest\_enabled) | Whether to enable encryption of data at rest.                                                                                                                                                                                                                                                       | `bool`         | `false`                            |    no    |
| <a name="input_enforce_https"></a> [enforce\_https](#input\_enforce\_https)                                   | Whether or not to require HTTPS.                                                                                                                                                                                                                                                                    | `bool`         | `true`                             |    no    |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version)                                | The engine version of open search                                                                                                                                                                                                                                                                   | `string`       | `"OpenSearch_2.13"`                |    no    |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count)                                | The number of instance                                                                                                                                                                                                                                                                              | `number`       | `1`                                |    no    |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size)                                   | The size of instance                                                                                                                                                                                                                                                                                | `string`       | `"t2.micro.search"`                |    no    |
| <a name="input_principal_roles"></a> [principal\_roles](#input\_principal\_roles)                             | List of priciple roles                                                                                                                                                                                                                                                                              | `list(string)` | `null`                             |    no    |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids)                  | Security group IDs that will be used in additional to the default ones.                                                                                                                                                                                                                             | `list(string)` | n/a                                |   yes    |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)                                            | The subnet ids of clusters                                                                                                                                                                                                                                                                          | `list(string)` | n/a                                |   yes    |
| <a name="input_tls_security_policy"></a> [tls\_security\_policy](#input\_tls\_security\_policy)               | Name of the TLS security policy that needs to be applied to the HTTPS endpoint. For valid values, refer to the AWS documentation: https://docs.aws.amazon.com/opensearch-service/latest/APIReference/API_DomainEndpointOptions.html#opensearchservice-Type-DomainEndpointOptions-TLSSecurityPolicy. | `string`       | `"Policy-Min-TLS-1-2-PFS-2023-10"` |    no    |
| <a name="input_zone_awareness_enabled"></a> [zone\_awareness\_enabled](#input\_zone\_awareness\_enabled)      | Whether zone awareness is enabled, set to true for multi-az deployment.                                                                                                                                                                                                                             | `bool`         | `false`                            |    no    |

## Outputs

| Name                                                         | Description         |
|--------------------------------------------------------------|---------------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Opensearch endpoint |

<!-- END_TF_DOCS -->
