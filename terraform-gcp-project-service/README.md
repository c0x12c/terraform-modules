# Terraform Google Project Service Module

This Terraform module allows management of a single API service for a Google Cloud project.

## Usage

### Create Google Project Service

```hcl
module "project_service" {
  source  = "github.com/spartan-stratos/terraform-modules//gcp/workload-identity?ref=v0.1.5"

  project_id = "example-project"
  services = [
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "compute.googleapis.com",
    "autoscaling.googleapis.com",
    "dns.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "redis.googleapis.com",
    "cloudscheduler.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "cloudtasks.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbilling.googleapis.com",
    "apikeys.googleapis.com",
    "admin.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
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

| Name                                                                                                                             | Type     |
|----------------------------------------------------------------------------------------------------------------------------------|----------|
| [google_project_service.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name                                                                                         | Description                                                                                                                                                              | Type           | Default | Required |
|----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_disable_on_destroy"></a> [disable\_on\_destroy](#input\_disable\_on\_destroy) | If `true` or unset, disable the service when the Terraform resource is destroyed. If `false`, the service will be left enabled when the Terraform resource is destroyed. | `bool`         | `false` |    no    |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                           | The ID of the project in which the resource belongs.                                                                                                                     | `string`       | n/a     |   yes    |
| <a name="input_services"></a> [services](#input\_services)                                   | A list of services to enable.                                                                                                                                            | `list(string)` | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
