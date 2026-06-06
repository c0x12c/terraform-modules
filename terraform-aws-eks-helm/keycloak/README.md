# EKS-Helm/Keycloak

This module helps install and configure Keycloak for EKS cluster via Helm chart.

## Usage

### Install Keycloak

```hcl
module "eks_helm_keycloak" {
  source = "github.com/spartan-stratos/terraform-modules//aws/eks-helm/keycloak?ref=v0.3.1"

  create_postgresql   = false
  postgresql_host     = "db_host"
  postgresql_db_name  = "db_name"
  postgresql_username = "db_username"
  postgresql_password = "db_password"

  create_ingress     = true
  ingress_class_name = "alb"
  ingress_hostname   = "keycloak.example.com"
  
  node_selector = {}
  tolerations = []
}

```

## Examples

- [Example](./examples/complete)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm)                | >=2.16.1 |

## Providers

| Name                                                       | Version  |
|------------------------------------------------------------|----------|
| <a name="provider_helm"></a> [helm](#provider\_helm)       | >=2.16.1 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a      |

## Modules

No modules.

## Resources

| Name                                                                                                                           | Type     |
|--------------------------------------------------------------------------------------------------------------------------------|----------|
| [helm_release.keycloak](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                  | resource |
| [random_password.keycloak_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)   | resource |
| [random_password.postgresql_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name                                                                                          | Description                                                                                                                                          | Type                | Default            | Required |
|-----------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|--------------------|:--------:|
| <a name="input_create_ingress"></a> [create\_ingress](#input\_create\_ingress)                | Whether to create the ingress                                                                                                                        | `bool`              | `true`             |    no    |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace)          | Determines whether a new namespace should be created. Set to 'true' to create the namespace; otherwise, set to 'false' to use an existing namespace. | `bool`              | `true`             |    no    |
| <a name="input_create_postgresql"></a> [create\_postgresql](#input\_create\_postgresql)       | n/a                                                                                                                                                  | `bool`              | `true`             |    no    |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version)  | The chart version of keycloak                                                                                                                        | `string`            | `"24.4.13"`        |    no    |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name)     | The Helm release of the services.                                                                                                                    | `string`            | `"metrics-server"` |    no    |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name)  | Ingress class name                                                                                                                                   | `string`            | `"alb"`            |    no    |
| <a name="input_ingress_group_name"></a> [ingress\_group\_name](#input\_ingress\_group\_name)  | Ingress group name                                                                                                                                   | `string`            | `"external"`       |    no    |
| <a name="input_ingress_hostname"></a> [ingress\_hostname](#input\_ingress\_hostname)          | Hostname for the ingress                                                                                                                             | `string`            | `""`               |    no    |
| <a name="input_ingress_path"></a> [ingress\_path](#input\_ingress\_path)                      | Path for the ingress                                                                                                                                 | `string`            | `"/*"`             |    no    |
| <a name="input_keycloak_cpu"></a> [keycloak\_cpu](#input\_keycloak\_cpu)                      | Keycloak cpu                                                                                                                                         | `string`            | `"450m"`           |    no    |
| <a name="input_keycloak_memory"></a> [keycloak\_memory](#input\_keycloak\_memory)             | Keycloak memory                                                                                                                                      | `string`            | `"1024Mi"`         |    no    |
| <a name="input_namespace"></a> [namespace](#input\_namespace)                                 | The Namespace of the services.                                                                                                                       | `string`            | `"keycloak"`       |    no    |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector)                   | Node selector for the keycloak                                                                                                                       | `map(string)`       | `{}`               |    no    |
| <a name="input_postgresql_db_name"></a> [postgresql\_db\_name](#input\_postgresql\_db\_name)  | Name of the database                                                                                                                                 | `string`            | `"keycloak"`       |    no    |
| <a name="input_postgresql_host"></a> [postgresql\_host](#input\_postgresql\_host)             | Host for the external database                                                                                                                       | `string`            | `""`               |    no    |
| <a name="input_postgresql_password"></a> [postgresql\_password](#input\_postgresql\_password) | Password for the database                                                                                                                            | `string`            | `null`             |    no    |
| <a name="input_postgresql_username"></a> [postgresql\_username](#input\_postgresql\_username) | Username for the database                                                                                                                            | `string`            | `"keycloak"`       |    no    |
| <a name="input_storage_class_name"></a> [storage\_class\_name](#input\_storage\_class\_name)  | Storage class name                                                                                                                                   | `string`            | `""`               |    no    |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations)                           | Tolerations for the keycloak                                                                                                                         | `list(map(string))` | `[]`               |    no    |

## Outputs

| Name                                                                                      | Description |
|-------------------------------------------------------------------------------------------|-------------|
| <a name="output_keycloak_password"></a> [keycloak\_password](#output\_keycloak\_password) | n/a         |
| <a name="output_keycloak_username"></a> [keycloak\_username](#output\_keycloak\_username) | n/a         |

<!-- END_TF_DOCS -->
