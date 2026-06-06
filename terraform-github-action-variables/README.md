# GitHub Actions Variables Terraform sub-module

This module creates list of GitHub Actions variables from input.

## Usage

### Create a GitHub Actions variables sub-module only

```hcl
module "github_actions_variables" {
  source  = "c0x12c/action-variables/github"
  version = "~> 1.0.0"

  repository = "service-platform"
  variables = {
    "VARIABLE" = "value"
  }
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                             | Version   |
|------------------------------------------------------------------|-----------|
| <a name="requirement_github"></a> [github](#requirement\_github) | \>= 6.4.0 |

## Providers

| Name                                                       | Version   |
|------------------------------------------------------------|-----------|
| <a name="provider_github"></a> [github](#provider\_github) | \>= 6.4.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                               | Type     |
|------------------------------------------------------------------------------------------------------------------------------------|----------|
| [github_actions_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |

## Inputs

| Name                                                             | Description | Type          | Default | Required |
|------------------------------------------------------------------|-------------|---------------|---------|:--------:|
| <a name="input_repository"></a> [repository](#input\_repository) | n/a         | `string`      | n/a     |   yes    |
| <a name="input_variables"></a> [variables](#input\_variables)    | n/a         | `map(string)` | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->