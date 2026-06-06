# GitHub Actions Terraform module

This module creates list of GitHub Actions secrets and variables from input.

## Usage

### Create a GitHub Actions module

```hcl
module "github_actions" {
  source  = "c0x12c/actions/github"
  version = "~> 1.0.0"

  repository_secrets = {
    "service-platform" = {
      "SECRETS_A" = "value"
      "SECRETS_B" = "value"
    }
    "web-platform" = {
      "SECRETS_A" = "value"
      "SECRETS_B" = "value"
    }
  }
  repository_variables = {}
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_action-secret"></a> [action-secret](#module\_action-secret) | c0x12c/action-secrets/github | ~> 1.0.1 |
| <a name="module_action-variables"></a> [action-variables](#module\_action-variables) | c0x12c/action-variable/github | ~> 1.0.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_repository_secrets"></a> [repository\_secrets](#input\_repository\_secrets) | A map of maps of repository and GitHub Actions secrets. | `map(map(string))` | `{}` | no |
| <a name="input_repository_variables"></a> [repository\_variables](#input\_repository\_variables) | A map of maps of repository and GitHub Actions variables. | `map(map(string))` | `{}` | no |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
