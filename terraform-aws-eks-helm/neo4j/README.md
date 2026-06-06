# AWS EKS Neo4j Helm Chart Deployment Terraform Module

This Terraform module is used to deploy the Neo4j Helm chart on an AWS EKS cluster, leveraging Elastic File System (EFS)
for persistent storage and various Kubernetes and Helm configurations.

## Usage

### Create a Neo4j Helm Chart Deployment

```hcl
module "neo4j" {
  source = "github.com/spartan-stratos/terraform-modules//aws/eks-helm/neo4j?ref=v0.3.0"

  domain = "example.com"
  efs_id = "example-id"

  neo4j_plugins = [
    "https://github.com/neo4j/graph-data-science/releases/download/2.13.2/neo4j-graph-data-science-2.13.2.jar",
    "https://github.com/neo4j/apoc/releases/download/5.26.0/apoc-5.26.0-core.jar"
  ]

  node_selector = {}
  tolerations = []
}

```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm)                | >=2.16.1  |

## Providers

| Name                                                                   | Version   |
|------------------------------------------------------------------------|-----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)                      | >= 5.75.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm)                   | >=2.16.1  |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a       |
| <a name="provider_random"></a> [random](#provider\_random)             | n/a       |

## Modules

No modules.

## Resources

| Name                                                                                                                                                        | Type     |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_efs_access_point.neo4j_home](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point)                             | resource |
| [helm_release.neo4j](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                                                  | resource |
| [kubernetes_persistent_volume.neo4j_home](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume)             | resource |
| [kubernetes_persistent_volume_claim.neo4j_home](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [random_password.neo4j_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                   | resource |

## Inputs

| Name                                                                                                       | Description                                                                                                                                          | Type                | Default                        | Required |
|------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|--------------------------------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version)                                | The version of the Neo4J Helm chart being deployed.                                                                                                  | `string`            | `"0.2.0"`                      |    no    |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace)                       | Determines whether a new namespace should be created. Set to 'true' to create the namespace; otherwise, set to 'false' to use an existing namespace. | `bool`              | `true`                         |    no    |
| <a name="input_custom_neo4j_config"></a> [custom\_neo4j\_config](#input\_custom\_neo4j\_config)            | Custom configuration settings for Neo4J.                                                                                                             | `string`            | `null`                         |    no    |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size)                                            | The size of the disk to be allocated for Neo4J storage.                                                                                              | `string`            | `"8Gi"`                        |    no    |
| <a name="input_domain"></a> [domain](#input\_domain)                                                       | The root domain of project                                                                                                                           | `string`            | n/a                            |   yes    |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id)                                                     | The ID of the EFS (Elastic File System) used for mounting the Neo4J home directory.                                                                  | `string`            | n/a                            |   yes    |
| <a name="input_efs_neo4j_access_point"></a> [efs\_neo4j\_access\_point](#input\_efs\_neo4j\_access\_point) | The specific access point within the EFS for the Neo4J home directory.                                                                               | `string`            | `"/neo4j-home"`                |    no    |
| <a name="input_efs_storage_class_name"></a> [efs\_storage\_class\_name](#input\_efs\_storage\_class\_name) | The storage class name used for Persistent Volumes with EFS.                                                                                         | `string`            | `"efs"`                        |    no    |
| <a name="input_force_update"></a> [force\_update](#input\_force\_update)                                   | Indicates whether updates should be forced, even if they might result in resource recreation. Set to 'true' to force updates.                        | `bool`              | `true`                         |    no    |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name)                  | The name of the Helm release for the Neo4J deployment.                                                                                               | `string`            | `"neo4j"`                      |    no    |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name)               | The ingress class name of Neo4j ingress                                                                                                              | `string`            | `"alb"`                        |    no    |
| <a name="input_ingress_group_name"></a> [ingress\_group\_name](#input\_ingress\_group\_name)               | The ingress group name of Neo4j ingress                                                                                                              | `string`            | `"external"`                   |    no    |
| <a name="input_namespace"></a> [namespace](#input\_namespace)                                              | The Kubernetes namespace where Neo4J will be installed. Defaults to 'neo4j'.                                                                         | `string`            | `"neo4j"`                      |    no    |
| <a name="input_neo4j_cpu"></a> [neo4j\_cpu](#input\_neo4j\_cpu)                                            | The CPU request and limit for Neo4j                                                                                                                  | `string`            | `"1950m"`                      |    no    |
| <a name="input_neo4j_dns_name"></a> [neo4j\_dns\_name](#input\_neo4j\_dns\_name)                           | The Neo4j DNS name                                                                                                                                   | `string`            | `"neo4j"`                      |    no    |
| <a name="input_neo4j_fqdn"></a> [neo4j\_fqdn](#input\_neo4j\_fqdn)                                         | FQDN of Neo4j service                                                                                                                                | `string`            | `""`                           |    no    |
| <a name="input_neo4j_memory"></a> [neo4j\_memory](#input\_neo4j\_memory)                                   | The memory request and limit for Neo4j                                                                                                               | `string`            | `"3.5Gi"`                      |    no    |
| <a name="input_neo4j_password"></a> [neo4j\_password](#input\_neo4j\_password)                             | The password for the Neo4J database.                                                                                                                 | `string`            | `null`                         |    no    |
| <a name="input_neo4j_plugins"></a> [neo4j\_plugins](#input\_neo4j\_plugins)                                | A list of URLs pointing to the Neo4J plugins to be installed.                                                                                        | `list(string)`      | `[]`                           |    no    |
| <a name="input_neo4j_plugins_dir"></a> [neo4j\_plugins\_dir](#input\_neo4j\_plugins\_dir)                  | The directory where Neo4J plugins will be stored.                                                                                                    | `string`            | `"/opt/bitnami/neo4j/plugins"` |    no    |
| <a name="input_neo4j_procedures"></a> [neo4j\_procedures](#input\_neo4j\_procedures)                       | A comma-separated list of Neo4j procedures and functions to allow.                                                                                   | `string`            | `"gds.*,apoc.*"`               |    no    |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector)                                | Node selector for the ingress controller                                                                                                             | `map(string)`       | `{}`                           |    no    |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations)                                        | Tolerations for the ingress controller                                                                                                               | `list(map(string))` | `[]`                           |    no    |

## Outputs

| Name                                                                             | Description                                   |
|----------------------------------------------------------------------------------|-----------------------------------------------|
| <a name="output_neo4j_password"></a> [neo4j\_password](#output\_neo4j\_password) | The password for accessing the Neo4j database |
| <a name="output_neo4j_username"></a> [neo4j\_username](#output\_neo4j\_username) | The username for accessing the Neo4j database |

<!-- END_TF_DOCS -->
