# GCP IAM Member module

This Terraform module allows managing IAM members and their roles within the GCP project.

## Usage

### Create GCP IAM Member module

```hcl
module "iam_member" {
  source  = "github.com/spartan-stratos/terraform-modules//gcp/iam-member?ref=v0.1.5"

  project_id = "example"
  user_groups = {
    "Dev" = {
      members = [
        "member_1@example.com",
        "member_2@example.com",
      ]
      roles = [
        "roles/editor",
        "roles/secretmanager.secretAccessor"
      ]
    }
    "Admin" = {
      members = [
        "admin@example.com",
      ]
      roles = [
        "roles/admin",
      ]
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

| Name                                                                                                                                | Type     |
|-------------------------------------------------------------------------------------------------------------------------------------|----------|
| [google_project_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |

## Inputs

| Name                                                                  | Description                                                    | Type                                                                                            | Default | Required |
|-----------------------------------------------------------------------|----------------------------------------------------------------|-------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)    | The ID of the Google Cloud project.                            | `string`                                                                                        | n/a     |   yes    |
| <a name="input_user_groups"></a> [user\_groups](#input\_user\_groups) | A map of user groups: including associating members and roles. | <pre>map(object({<br/>    members = list(string)<br/>    roles   = list(string)<br/>  }))</pre> | `{}`    |    no    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
