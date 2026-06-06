# GitHub Actions Secrets Terraform sub-module

This module creates list of GitHub Actions secrets from input.

## Usage

### Create a GitHub Actions secrets sub-module only

```hcl
module "github_actions_secrets" {
  source  = "github.com/spartan-stratos/terraform-modules//github/actions/modules/action-secrets?ref=v0.1.10"

  repository = "service-platform"
  secrets = {
    "SECRET" = "value"
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

| Name                                                                                                                           | Type     |
|--------------------------------------------------------------------------------------------------------------------------------|----------|
| [github_actions_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |

## Inputs

| Name                                                             | Description | Type          | Default | Required |
|------------------------------------------------------------------|-------------|---------------|---------|:--------:|
| <a name="input_repository"></a> [repository](#input\_repository) | n/a         | `string`      | n/a     |   yes    |
| <a name="input_secrets"></a> [secrets](#input\_secrets)          | n/a         | `map(string)` | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->