# EFS sub-module

Terraform EFS sub-module to create EFS resources on AWS.

## Usage

### Create EFS

```hcl
module "efs" {
  source  = "c0x12c/eks-efs/aws"

  name                      = local.cluster_name
  environment               = var.environment
  private_subnet_ids        = var.private_subnet_ids
  cluster_security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id

  filesystem_encrypted        = var.filesystem_encrypted
  filesystem_performance_mode = var.filesystem_performance_mode
  filesystem_throughput_mode  = var.filesystem_throughput_mode
  efs_storage_class_name      = var.efs_storage_class_name
  efs_backup_policy_status    = var.efs_backup_policy_status
  efs_lifecycle_policy        = var.efs_lifecycle_policy
}
```

## Examples

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                         | Version   |
|------------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.9.8  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | >= 5.75   |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33.0 |

## Providers

| Name                                                                   | Version   |
|------------------------------------------------------------------------|-----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)                      | >= 5.75   |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.33.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                              | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_efs_backup_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy)       | resource |
| [aws_efs_file_system.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system)            | resource |
| [aws_efs_mount_target.mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [kubernetes_storage_class.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |

## Inputs

| Name                                                                                                                    | Description                                                                                       | Type                                                                                                                                         | Default            | Required |
|-------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|--------------------|:--------:|
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id)     | Security group to apply to this cluster.                                                          | `string`                                                                                                                                     | n/a                |   yes    |
| <a name="input_efs_backup_policy_status"></a> [efs\_backup\_policy\_status](#input\_efs\_backup\_policy\_status)        | Enable/disable backup for EFS Filesystem.  Value should be ENABLE/DISABLED.  Defaults to DISABLED | `string`                                                                                                                                     | `"DISABLED"`       |    no    |
| <a name="input_efs_filesystem_name"></a> [efs\_filesystem\_name](#input\_efs\_filesystem\_name)                         | To specify the name of efs filesystem in case overwrite the default one                           | `string`                                                                                                                                     | `null`             |    no    |
| <a name="input_efs_lifecycle_policy"></a> [efs\_lifecycle\_policy](#input\_efs\_lifecycle\_policy)                      | Lifecycle Policy for the EFS Filesystem                                                           | <pre>list(object({<br/>    transition_to_ia                    = string<br/>    transition_to_primary_storage_class = string<br/>  }))</pre> | `[]`               |    no    |
| <a name="input_efs_storage_class_name"></a> [efs\_storage\_class\_name](#input\_efs\_storage\_class\_name)              | n/a                                                                                               | `string`                                                                                                                                     | `"efs"`            |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                     | Environment where the resources will be created.                                                  | `string`                                                                                                                                     | n/a                |   yes    |
| <a name="input_filesystem_encrypted"></a> [filesystem\_encrypted](#input\_filesystem\_encrypted)                        | Enable encryption for EFS                                                                         | `bool`                                                                                                                                       | `true`             |    no    |
| <a name="input_filesystem_performance_mode"></a> [filesystem\_performance\_mode](#input\_filesystem\_performance\_mode) | The file system performance mode.                                                                 | `string`                                                                                                                                     | `"generalPurpose"` |    no    |
| <a name="input_filesystem_throughput_mode"></a> [filesystem\_throughput\_mode](#input\_filesystem\_throughput\_mode)    | Throughput mode for the file system.                                                              | `string`                                                                                                                                     | `"bursting"`       |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                          | Name of the resources will be created.                                                            | `string`                                                                                                                                     | n/a                |   yes    |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids)                            | A list of private subnet IDs for the EFS                                                          | `list(string)`                                                                                                                               | n/a                |   yes    |

## Outputs

| Name                                          | Description |
|-----------------------------------------------|-------------|
| <a name="output_efs"></a> [efs](#output\_efs) | n/a         |

<!-- END_TF_DOCS -->
