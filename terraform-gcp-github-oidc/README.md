# GCP Github OIDC Terraform module

Terraform module which configure Workload Identity pools and providers for authenticating to GCP using GitHub Actions
OIDC tokens.

This module will create the following components:

- Creation of a Workload Identity pool.
- Configuring a Workload Identity provider.
- Granting external identities necessary IAM roles on Service Accounts.

## Usage

### Create GCP Github OIDC

```hcl
module "github_oidc" {
  source  = "github.com/spartan-stratos/terraform-modules//gcp/github-oidc?ref=v0.1.0"

  gcp_pool_id            = "github-actions-pool"
  gcp_project_id         = "my-gcp-project"
  gcp_provider_id        = "github-provider"
  gcp_service_account_id = "github-actions-sa"
  github_org             = "my-org"
  github_repos           = ["example-repo", "my-repo"]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                            | Version      |
|---------------------------------------------------------------------------------|--------------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)       | >= 1.9.8     |
| <a name="requirement_google"></a> [google](#requirement\_google)                | \>= 6.12, <7 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | \>= 6.12, <7 |

## Providers

No providers.

## Modules

| Name                                                        | Source                                                                  | Version |
|-------------------------------------------------------------|-------------------------------------------------------------------------|---------|
| <a name="module_gh_oidc"></a> [gh\_oidc](#module\_gh\_oidc) | terraform-google-modules/github-actions-runners/google//modules/gh-oidc | 4.0.0   |

## Resources

No resources.

## Inputs

| Name                                                                                                       | Description                                                                | Type        | Default | Required |
|------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|-------------|---------|:--------:|
| <a name="input_gcp_pool_id"></a> [gcp\_pool\_id](#input\_gcp\_pool\_id)                                    | The ID of the GCP node pool where resources will be deployed.              | `string`    | n/a     |   yes    |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id)                           | The GCP project ID under which the resources are managed.                  | `string`    | n/a     |   yes    |
| <a name="input_gcp_provider_id"></a> [gcp\_provider\_id](#input\_gcp\_provider\_id)                        | The ID of the GCP provider used for managing infrastructure.               | `string`    | n/a     |   yes    |
| <a name="input_gcp_service_account_id"></a> [gcp\_service\_account\_id](#input\_gcp\_service\_account\_id) | The ID of the GCP service account used for authentication and permissions. | `string`    | n/a     |   yes    |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org)                                         | The GitHub organization where the repositories are located.                | `string`    | n/a     |   yes    |
| <a name="input_github_repos"></a> [github\_repos](#input\_github\_repos)                                   | A list of GitHub repositories to be managed or integrated.                 | `list(any)` | `[]`    |    no    |

## Outputs

| Name                                                                                                                   | Description                                                                            |
|------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email)                | The email address of the GCP service account.                                          |
| <a name="output_workload_identity_provider"></a> [workload\_identity\_provider](#output\_workload\_identity\_provider) | The full resource name of the Workload Identity Provider in the specified GCP project. |

<!-- END_TF_DOCS -->
