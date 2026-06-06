# AWS IAM SSO module

Terraform AWS IAM SSO module to manage AWS Single Sign-On (SSO) settings, users, groups, assignments, and identity store
resources.

## Usage

### Create AWS IAM SSO

```hcl
module "iam_sso" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/iam-sso?ref=v0.1.0"

  groups = {
    "Developers" = {
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
  }
}
```

## Examples

- [Example complete](./examples/complete/)

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

| Name                                                   | Source  | Version |
|--------------------------------------------------------|---------|---------|
| <a name="module_groups"></a> [groups](#module\_groups) | ./group | n/a     |

## Resources

| Name                                                                                                                                                              | Type        |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances)                                   | data source |
| [aws_identitystore_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user)                                     | resource    |
| [aws_ssoadmin_account_assignment.group_assignment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment)       | resource    |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group)                                   | resource    |
| [aws_identitystore_group_membership.group_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource    |

## Inputs

| Name                                                 | Description                                                              | Type                                                                                                                                                                                                                                                                                                                                                 | Default | Required |
|------------------------------------------------------|--------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_groups"></a> [groups](#input\_groups) | A map of IAM SSO groups, their users, AWS accounts, and permission sets. | <pre>map(object({<br/>    # Map of AWS account IDs to permission set ARNs<br/>    aws_accounts = optional(map(map(string)))<br/>    users = optional(<br/>      map(<br/>        object({<br/>          first_name = string<br/>          last_name  = string<br/>          user_name  = string<br/>        })<br/>      )<br/>    )<br/>  }))</pre> | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
