# Datadog Mono Monitor module

Terraform module to create Datadog team.

## Usage

### Create Datadog service monitors

```hcl
module "datadog_be_team" {
  source = "terraform.c0x12c.com/c0x12c/team/datadog"

  team_name        = "Prj X oncall team"
  team_handle      = "prj-x-oncall"
  team_description = "Prj X oncall team description"

  team_members = local.team_members
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_team.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/team) | resource |
| [datadog_team_membership.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/team_membership) | resource |
| [datadog_user.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_team_description"></a> [team\_description](#input\_team\_description) | A description for the Datadog team. | `string` | n/a | yes |
| <a name="input_team_handle"></a> [team\_handle](#input\_team\_handle) | The handle for the Datadog team, which must be unique. | `string` | n/a | yes |
| <a name="input_team_members"></a> [team\_members](#input\_team\_members) | A list of email addresses for the users to be added to the team. | `list(string)` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | The name of the Datadog team. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | The ID of the created Datadog team. |
| <a name="output_team_members_ids"></a> [team\_members\_ids](#output\_team\_members\_ids) | The list of user IDs for the members of the team. |
<!-- END_TF_DOCS -->
