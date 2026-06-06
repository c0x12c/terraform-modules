# EFS sub-module

Terraform EFS sub-module to create EFS resources on AWS.

## Usage

### Create EFS

```hcl
module "efs" {
  source = "github.com/spartan-stratos/terraform-modules//aws/efs?ref=v0.1.78"

  name               = "example"
  subnet_ids         = []
  allowed_security_group_ids = []
  vpc_id             = "vpc-123456"

  efs_access_points = {
    example = {
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/var/www/html"
        creation_info = {
          owner_gid = 1000
          owner_uid = 1000
          permissions = "755"
        }
      }
    }
  }
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

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                              | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_efs_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point)         | resource    |
| [aws_efs_backup_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy)       | resource    |
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system)           | resource    |
| [aws_efs_mount_target.mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource    |
| [aws_security_group.efs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)           | resource    |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc)                                | data source |

## Inputs

| Name                                                                                                                    | Description                                                                                       | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Default            | Required |
|-------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|:--------:|
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids)  | A list of security group IDs to allow access to the EFS                                           | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | n/a                |   yes    |
| <a name="input_efs_access_points"></a> [efs\_access\_points](#input\_efs\_access\_points)                               | n/a                                                                                               | <pre>map(object({<br/>    posix_user = optional(object({<br/>      gid = optional(number, 1000)<br/>      uid = optional(number, 1000)<br/>    }), { gid = 1000, uid = 1000 })  # Default posix_user<br/><br/>    root_directory = object({<br/>      path = string<br/>      creation_info = optional(object({<br/>        owner_gid = optional(number, 1000)<br/>        owner_uid = optional(number, 1000)<br/>        permissions = optional(string, "755")<br/>      }), { owner_gid = 1000, owner_uid = 1000, permissions = "755" }) # Default creation_info<br/>    })<br/>  }))</pre> | n/a                |   yes    |
| <a name="input_efs_backup_policy_status"></a> [efs\_backup\_policy\_status](#input\_efs\_backup\_policy\_status)        | Enable/disable backup for EFS Filesystem.  Value should be ENABLE/DISABLED.  Defaults to DISABLED | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `"DISABLED"`       |    no    |
| <a name="input_efs_lifecycle_policy"></a> [efs\_lifecycle\_policy](#input\_efs\_lifecycle\_policy)                      | Lifecycle Policy for the EFS Filesystem                                                           | <pre>list(object({<br/>    transition_to_ia                    = string<br/>    transition_to_primary_storage_class = string<br/>  }))</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `[]`               |    no    |
| <a name="input_filesystem_encrypted"></a> [filesystem\_encrypted](#input\_filesystem\_encrypted)                        | Enable encryption for EFS                                                                         | `bool`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `true`             |    no    |
| <a name="input_filesystem_performance_mode"></a> [filesystem\_performance\_mode](#input\_filesystem\_performance\_mode) | The file system performance mode.                                                                 | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `"generalPurpose"` |    no    |
| <a name="input_filesystem_throughput_mode"></a> [filesystem\_throughput\_mode](#input\_filesystem\_throughput\_mode)    | Throughput mode for the file system.                                                              | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `"bursting"`       |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                          | Name of the resources will be created.                                                            | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | n/a                |   yes    |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)                                                      | A list subnet IDs for the EFS                                                                     | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | n/a                |   yes    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                                  | VPC ID to deploy to                                                                               | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | n/a                |   yes    |

## Outputs

| Name                                                                               | Description |
|------------------------------------------------------------------------------------|-------------|
| <a name="output_access_points"></a> [access\_points](#output\_access\_points)      | n/a         |
| <a name="output_file_system_id"></a> [file\_system\_id](#output\_file\_system\_id) | n/a         |

<!-- END_TF_DOCS -->
