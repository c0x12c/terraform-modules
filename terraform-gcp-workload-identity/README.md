# Terraform Google Workload Identity Module

This Terraform module creates Google Workload Identity resources.

This module will create the following components:

- Creates a workload identity pool.
- Create a list of workload identity providers.
- Assign IAM roles to the service account, allowing it to access resources based on the role and the principal set
  defined by the workload identity pool.

## Usage

### Create Google Workload Identity resources

```hcl
module "workload_identity" {
  source  = "github.com/spartan-stratos/terraform-modules//gcp/workload-identity?ref=v0.1.5"

  pool_id            = "example-pool"
  project_id         = "example-project"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = "pipeline-ops@example-project.iam.gserviceaccount.com"

  provider_list = {
    github  = "https://token.actions.githubusercontent.com"
    jenkins = "https://jenkins.<domain-name>.dev/oidc"
  }
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                            | Version   |
|---------------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)       | \>= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google)                | \>= 6.12  |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | \>= 6.12  |

## Providers

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="provider_google"></a> [google](#provider\_google)                | \>= 6.12 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | \>= 6.12 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                           | Type        |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_iam_workload_identity_pool.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool)                            | resource    |
| [google_iam_workload_identity_pool_provider.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider)          | resource    |
| [google_service_account_iam_binding.admin_account_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding)             | resource    |
| [google-beta_google_iam_workload_identity_pool.this](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_iam_workload_identity_pool) | data source |

## Inputs

| Name                                                                                               | Description                                                                                              | Type       | Default | Required |
|----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|------------|---------|:--------:|
| <a name="input_create_identity_pool"></a> [create\_identity\_pool](#input\_create\_identity\_pool) | Specifies whether to create a workload identity pool or use existing one.                                | `bool`     | `true`  |    no    |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id)                                          | The workload identity pool id                                                                            | `string`   | n/a     |   yes    |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                                 | The ID of the project in which the resource is created.                                                  | `string`   | n/a     |   yes    |
| <a name="input_provider_list"></a> [provider\_list](#input\_provider\_list)                        | A map of provider configurations used to manage resources for different services (e.g: GitHub, Jenkins). | `map(any)` | `{}`    |    no    |
| <a name="input_role"></a> [role](#input\_role)                                                     | The role to be assigned to the service account.                                                          | `string`   | n/a     |   yes    |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id)       | The service account ID to bind to a workload identity pool IAM role.                                     | `string`   | n/a     |   yes    |

## Outputs

| Name                                                                                                                   | Description                            |
|------------------------------------------------------------------------------------------------------------------------|----------------------------------------|
| <a name="output_workload_identity_provider"></a> [workload\_identity\_provider](#output\_workload\_identity\_provider) | A list of workload identity providers. |

<!-- END_TF_DOCS -->
