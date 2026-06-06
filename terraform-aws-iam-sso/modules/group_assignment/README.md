# AWS SSO Admin Account Assignment sub-module

Terraform AWS SSO Admin Account Assignment sub-module to manage account assignments on AWS.

## Usage

### Create AWS SSO Admin Account Assignment

```hcl
module "iam_sso_group_assignment" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/iam-sso/modules/group_assignment?ref=v0.1.0"

  aws_account_id = "0123456789"
  group_id       = "example-group-id-1234-5678-abcd-ef1234567890"
  permission_set_arns = {
    "PermissionSetName1" = "arn:aws:sso:::permissionSet/permissionSetArn1"
    "PermissionSetName2" = "arn:aws:sso:::permissionSet/permissionSetArn2"
  }
}
```

## Examples

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | \>=5.75  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | \>=5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                        | Type        |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_ssoadmin_account_assignment.group_assignment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource    |
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances)                             | data source |

## Inputs

| Name                                                                                            | Description                                                                                                                                                   | Type          | Default | Required |
|-------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id)                | The AWS account ID to which the IAM SSO group will be assigned.                                                                                               | `string`      | n/a     |   yes    |
| <a name="input_group_id"></a> [group\_id](#input\_group\_id)                                    | The ID of the IAM SSO group to assign to the AWS account.                                                                                                     | `string`      | n/a     |   yes    |
| <a name="input_permission_set_arns"></a> [permission\_set\_arns](#input\_permission\_set\_arns) | A map of permission set names to their corresponding ARN values. Each key represents a permission set name and each value is the ARN for that permission set. | `map(string)` | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
