# Terraform Google Cloud Storage Bucket Module

This Terraform module creates a Google Cloud Storage bucket.

This module will create the following components:

- Creates a bucket.
- Create bucket and object ACLs (Access Control Lists) when public access is enabled.

## Usage

### Create GCP Service Account

```hcl
module "storage_bucket" {
  source = "github.com/spartan-stratos/terraform-modules//gcp/storage-bucket?ref=v0.6.5"

  bucket_name = "example-bucket"
  environment = "example-environment"

  soft_delete_policy = {
    retention_duration_seconds = 604800 # 7 days
  }

  lifecycle_rules = [
    {
      age  = 30
      type = "Delete"
    },
    {
      age  = 60
      type = "SetStorageClass"
    }
  ]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google)          | >= 6.12  |

## Providers

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                             | Type     |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)                                                      | resource |
| [google_storage_bucket_access_control.public_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_access_control)                 | resource |
| [google_storage_bucket_iam_binding.users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding)                             | resource |
| [google_storage_bucket_iam_binding.viewers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding)                           | resource |
| [google_storage_bucket_iam_member.creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member)                             | resource |
| [google_storage_default_object_access_control.public_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_default_object_access_control) | resource |

## Inputs

| Name                                                                                                                      | Description                                                                                                                      | Type                                                                                                                                                                   | Default        | Required |
|---------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)                                                     | The name of the google bucket being created.                                                                                     | `string`                                                                                                                                                               | n/a            |   yes    |
| <a name="input_bucket_name_overwrite"></a> [bucket\_name\_overwrite](#input\_bucket\_name\_overwrite)                     | The overwrite name of the google bucket being created.                                                                           | `string`                                                                                                                                                               | `null`         |    no    |
| <a name="input_bucket_users"></a> [bucket\_users](#input\_bucket\_users)                                                  | A list of users who will have write access to the specified storage bucket.                                                      | `list`                                                                                                                                                                 | `[]`           |    no    |
| <a name="input_bucket_viewers"></a> [bucket\_viewers](#input\_bucket\_viewers)                                            | A list of users who will have read-only access to the specified storage bucket.                                                  | `list`                                                                                                                                                                 | `[]`           |    no    |
| <a name="input_cors_extra_headers"></a> [cors\_extra\_headers](#input\_cors\_extra\_headers)                              | The list of HTTP headers other than the simple response headers to give permission for the user-agent to share across domains.   | `list(string)`                                                                                                                                                         | `[]`           |    no    |
| <a name="input_cors_max_age_seconds"></a> [cors\_max\_age\_seconds](#input\_cors\_max\_age\_seconds)                      | The value, in seconds, to return in the Access-Control-Max-Age header used in preflight responses.                               | `number`                                                                                                                                                               | `600`          |    no    |
| <a name="input_cors_methods"></a> [cors\_methods](#input\_cors\_methods)                                                  | The list of HTTP methods on which to include CORS response headers.                                                              | `list(string)`                                                                                                                                                         | `[]`           |    no    |
| <a name="input_cors_origins"></a> [cors\_origins](#input\_cors\_origins)                                                  | The list of Origins eligible to receive CORS response headers.                                                                   | `list(string)`                                                                                                                                                         | `[]`           |    no    |
| <a name="input_enable_cors"></a> [enable\_cors](#input\_enable\_cors)                                                     | Enable the bucket's Cross-Origin Resource Sharing (CORS) configuration.                                                          | `bool`                                                                                                                                                                 | `false`        |    no    |
| <a name="input_enable_creator_policy"></a> [enable\_creator\_policy](#input\_enable\_creator\_policy)                     | Whether to allow bucket create objects on itself. Should be enabled if you use this as log bucket.                               | `bool`                                                                                                                                                                 | `false`        |    no    |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging)                                            | Whether to enable logging                                                                                                        | `bool`                                                                                                                                                                 | `false`        |    no    |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning)                                   | While set to true, versioning is fully enabled for this bucket.                                                                  | `bool`                                                                                                                                                                 | `false`        |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                       | Environment where the resources will be created.                                                                                 | `string`                                                                                                                                                               | n/a            |   yes    |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy)                                               | When deleting a bucket, this boolean option will delete all contained objects.                                                   | `bool`                                                                                                                                                                 | `false`        |    no    |
| <a name="input_is_listable"></a> [is\_listable](#input\_is\_listable)                                                     | Allow list object in a bucket                                                                                                    | `bool`                                                                                                                                                                 | `false`        |    no    |
| <a name="input_is_public"></a> [is\_public](#input\_is\_public)                                                           | Allow public access to a bucket                                                                                                  | `bool`                                                                                                                                                                 | `false`        |    no    |
| <a name="input_is_static_web"></a> [is\_static\_web](#input\_is\_static\_web)                                             | Set the bucket as static web                                                                                                     | `bool`                                                                                                                                                                 | `false`        |    no    |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules)                                         | List of lifecycle rules for the bucket                                                                                           | <pre>list(object({<br/>    age                        = number<br/>    type                       = string<br/>    days_since_noncurrent_time = number<br/>  }))</pre> | `[]`           |    no    |
| <a name="input_location"></a> [location](#input\_location)                                                                | The Google Cloud Storage Service location.                                                                                       | `string`                                                                                                                                                               | `"US"`         |    no    |
| <a name="input_main_page_suffix"></a> [main\_page\_suffix](#input\_main\_page\_suffix)                                    | Behaves as the bucket's directory index where missing objects are treated as potential directories.                              | `string`                                                                                                                                                               | `"index.html"` |    no    |
| <a name="input_not_found_page"></a> [not\_found\_page](#input\_not\_found\_page)                                          | The custom object to return when a requested resource is not found.                                                              | `string`                                                                                                                                                               | `"404.html"`   |    no    |
| <a name="input_public_access_prevention"></a> [public\_access\_prevention](#input\_public\_access\_prevention)            | Prevents public access to a bucket. Acceptable values are inherited or enforced.                                                 | `string`                                                                                                                                                               | `"inherited"`  |    no    |
| <a name="input_soft_delete_policy"></a> [soft\_delete\_policy](#input\_soft\_delete\_policy)                              | Optional soft delete policy                                                                                                      | <pre>object({<br/>    retention_duration_seconds = number<br/>  })</pre>                                                                                               | `null`         |    no    |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class)                                               | The Storage Class of the new bucket. Supported values include: STANDARD, MULTI\_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE. | `string`                                                                                                                                                               | `"STANDARD"`   |    no    |
| <a name="input_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#input\_uniform\_bucket\_level\_access) | Enables Uniform bucket-level access access to a bucket.                                                                          | `bool`                                                                                                                                                                 | `false`        |    no    |

## Outputs

| Name                                                                    | Description                              |
|-------------------------------------------------------------------------|------------------------------------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The Bucket name of the created resource. |
| <a name="output_bucket_url"></a> [bucket\_url](#output\_bucket\_url)    | The URI of the created resource.         |

<!-- END_TF_DOCS -->
