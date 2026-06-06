# Google Workspace Terraform module

This Terraform module provisions workspace group resources that manages workspace members.

## Usage

### Create Google Workspace module

```hcl
module "google_workspace" {
  source  = "c0x12c/google-workspace/gcp"
  version = "~> 1.0.0"

  domain = "example.com"
  groups = {
    "example_project_developers" = {
      name        = "Example Project Developers"
      description = "Team Example Project Developers"
      members = [
        "member_1",
        "member_2"
      ]
    }
  }
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_googleworkspace"></a> [googleworkspace](#requirement\_googleworkspace) | >= 0.7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_group"></a> [group](#module\_group) | c0x12c/google-workspace-group/gcp | ~> 1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | The domain associated with the Google Workspace account. | `string` | n/a | yes |
| <a name="input_groups"></a> [groups](#input\_groups) | A map of Google Workspace groups, where each group has a description, a name, and a list of member email addresses. This configuration allows for dynamic management of multiple groups and their members. | <pre>map(object({<br/>    description = string<br/>    name        = string<br/>    members     = list(string)<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
