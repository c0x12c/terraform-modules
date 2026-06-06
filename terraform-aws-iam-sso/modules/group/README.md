# AWS Identity Group sub-module

Terraform AWS Identity Group sub-module to create and manage groups and users on AWS.

## Usage

### Create AWS Identity Group

```hcl
module "iam_sso_group" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/iam-sso/modules/group?ref=v0.1.0"

  group_name = "Developers"

  users = {
    "sample.user@email.abc" = {
      first_name = "Sample"
      last_name  = "User"
      user_name  = "sample.user"
    },
  }

  aws_accounts = {
    "0123456789" = {
      "PermissionSetName1" = "arn:aws:sso:::permissionSet/permissionSetArn1"
      "PermissionSetName2" = "arn:aws:sso:::permissionSet/permissionSetArn2"
    }
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

| Name                                                                                      | Source              | Version |
|-------------------------------------------------------------------------------------------|---------------------|---------|
| <a name="module_group_assignments"></a> [group\_assignments](#module\_group\_assignments) | ../group_assignment | n/a     |
| <a name="module_users"></a> [users](#module\_users)                                       | ../user             | n/a     |

## Resources

| Name                                                                                                                                                              | Type        |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group)                                   | resource    |
| [aws_identitystore_group_membership.group_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource    |
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances)                                   | data source |

## Inputs

| Name                                                                     | Description                                                                                                                                                                                      | Type                                                                                                                  | Default | Required |
|--------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | A map of AWS account IDs to their respective permission set ARNs. Each key is an AWS account ID, and the value is another map where the keys are permission set names and values are their ARNs. | `map(map(string))`                                                                                                    | n/a     |   yes    |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name)       | The name of the IAM SSO group to be created.                                                                                                                                                     | `string`                                                                                                              | n/a     |   yes    |
| <a name="input_users"></a> [users](#input\_users)                        | A map of users to be added to the IAM SSO group. Each key is a user email address, and the value is an object that contains the user's first name, last name, and username.                      | <pre>map(object({<br/>    first_name = string<br/>    last_name  = string<br/>    user_name  = string<br/>  }))</pre> | `{}`    |    no    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
