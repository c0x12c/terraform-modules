# AWS EKS Managed Node Group

Terraform module which creates Amazon EKS (Kubernetes) Managed Node Group (MNG) resources.

This module will create the components below

- IAM Role for MNG to manage EC2, EKS permissions.
- MNG

## Usage

### Create EKS MNG

```hcl
module "mng" {
  source = "c0x12c/eks-managed-node-group/aws"

  name         = "mng"
  cluster_name = aws_eks_cluster.master.name
  subnet_ids = ["subnet-12345678a"]

  min_size     = 1
  max_size     = 5
  desired_size = 2

  instance_types = ["t2.large"]
  capacity_type = "ON_DEMAND"

  taints = [
    {
      key    = "dedicated"
      value  = "gpuGroup"
      effect = "NO_SCHEDULE"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.83  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.83 |

## Modules

No modules.

## Resources

| Name                                                                                                                                             | Type        |
|--------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group)                            | resource    |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                        | resource    |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                          | resource    |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)    | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                    | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)               | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                | data source |

## Inputs

| Name                                                                                                                            | Description                                                                                                                                                                                          | Type                                                                                                       | Default                                                   | Required |
|---------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|:--------:|
| <a name="input_capacity_type"></a> [capacity\_type](#input\_capacity\_type)                                                     | Type of capacity associated with the EKS Node Group. Valid values: `ON_DEMAND`, `SPOT`                                                                                                               | `string`                                                                                                   | `"ON_DEMAND"`                                             |    no    |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)                                                        | Name of associated EKS cluster                                                                                                                                                                       | `string`                                                                                                   | `null`                                                    |    no    |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version)                                               | The Kubernetes version to use for the EKS cluster                                                                                                                                                    | `string`                                                                                                   | n/a                                                       |   yes    |
| <a name="input_create"></a> [create](#input\_create)                                                                            | Determines whether to create EKS managed node group or not                                                                                                                                           | `bool`                                                                                                     | `true`                                                    |    no    |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size)                                                        | Desired number of instances/nodes                                                                                                                                                                    | `number`                                                                                                   | n/a                                                       |   yes    |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size)                                                                 | Disk size in GiB for nodes. Defaults to `20`. Only valid when `use_custom_launch_template` = `false`                                                                                                 | `number`                                                                                                   | `null`                                                    |    no    |
| <a name="input_force_update_version"></a> [force\_update\_version](#input\_force\_update\_version)                              | Force version update if existing pods are unable to be drained due to a pod disruption budget issue                                                                                                  | `bool`                                                                                                     | `false`                                                   |    no    |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies)    | Additional policies to be added to the IAM role                                                                                                                                                      | `map(string)`                                                                                              | `{}`                                                      |    no    |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description)                              | Description of the role                                                                                                                                                                              | `string`                                                                                                   | `null`                                                    |    no    |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name)                                                   | Name to use on IAM role created                                                                                                                                                                      | `string`                                                                                                   | `null`                                                    |    no    |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path)                                                   | IAM role path                                                                                                                                                                                        | `string`                                                                                                   | `null`                                                    |    no    |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role                                                                                                                      | `string`                                                                                                   | `null`                                                    |    no    |
| <a name="input_iam_role_policy_statements"></a> [iam\_role\_policy\_statements](#input\_iam\_role\_policy\_statements)          | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | `any`                                                                                                      | `[]`                                                      |    no    |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags)                                                   | A map of additional tags to add to the IAM role created                                                                                                                                              | `map(string)`                                                                                              | `{}`                                                      |    no    |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix)              | Determines whether the IAM role name (`iam_role_name`) is used as a prefix                                                                                                                           | `bool`                                                                                                     | `true`                                                    |    no    |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types)                                                  | Set of instance types associated with the EKS Node Group. Defaults to `["t3.medium"]`                                                                                                                | `list(string)`                                                                                             | `null`                                                    |    no    |
| <a name="input_labels"></a> [labels](#input\_labels)                                                                            | Key-value map of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed            | `map(string)`                                                                                              | `null`                                                    |    no    |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size)                                                                    | Maximum number of instances/nodes                                                                                                                                                                    | `number`                                                                                                   | n/a                                                       |   yes    |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size)                                                                    | Minimum number of instances/nodes                                                                                                                                                                    | `number`                                                                                                   | n/a                                                       |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                                                  | Name of the EKS managed node group                                                                                                                                                                   | `string`                                                                                                   | n/a                                                       |   yes    |
| <a name="input_node_group_version"></a> [node\_group\_version](#input\_node\_group\_version)                                    | Kubernetes version for the managed node group                                                                                                                                                        | `string`                                                                                                   | n/a                                                       |   yes    |
| <a name="input_node_repair_config"></a> [node\_repair\_config](#input\_node\_repair\_config)                                    | The node auto repair configuration for the node group                                                                                                                                                | <pre>object({<br/>    enabled = optional(bool, true)<br/>  })</pre>                                        | `null`                                                    |    no    |
| <a name="input_remote_access"></a> [remote\_access](#input\_remote\_access)                                                     | Configuration block with remote access settings. Only valid when `use_custom_launch_template` = `false`                                                                                              | `any`                                                                                                      | `{}`                                                      |    no    |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)                                                              | Identifiers of EC2 Subnets to associate with the EKS Node Group. These subnets must have the following resource tag: `kubernetes.io/cluster/CLUSTER_NAME`                                            | `list(string)`                                                                                             | `null`                                                    |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                  | A map of tags to add to all resources                                                                                                                                                                | `map(string)`                                                                                              | `{}`                                                      |    no    |
| <a name="input_taints"></a> [taints](#input\_taints)                                                                            | The Kubernetes taints to be applied to the nodes in the node group. Maximum of 50 taints per node group                                                                                              | <pre>list(object({<br/>    key    = string<br/>    value  = string<br/>    effect = string<br/>  }))</pre> | `null`                                                    |    no    |
| <a name="input_update_config"></a> [update\_config](#input\_update\_config)                                                     | Configuration block of settings for max unavailable resources during node group updates                                                                                                              | `map(string)`                                                                                              | <pre>{<br/>  "max_unavailable_percentage": 33<br/>}</pre> |    no    |

## Outputs

| Name                                                                                           | Description |
|------------------------------------------------------------------------------------------------|-------------|
| <a name="output_managed_node_group"></a> [managed\_node\_group](#output\_managed\_node\_group) | n/a         |
| <a name="output_node_role_arn"></a> [node\_role\_arn](#output\_node\_role\_arn)                | n/a         |

<!-- END_TF_DOCS -->
