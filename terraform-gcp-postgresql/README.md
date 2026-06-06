# Terraform Google Cloud SQL Module

This Terraform module creates a primary Cloud hosted SQL instance along with user-selected number of replicas.

This module will create the following components:

- Creates a primary instance.
- Create user-selected number of replicas.
- Create database.
- Create user-defined username password to access database.

## Usage

### Create Google Cloud SQL instance and replicas

```hcl
module "postgresql" {
  source = "../../"

  network_name = "example-vpc-name"
  project_id   = "example-project"
  region       = "us-west1"

  db_name  = "example-database"
  name     = "example"
  size     = 20
  username = "example-user"

  replica_count          = 1
  analytic_replica_count = 1
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google)          | \>= 6.12 |

## Providers

| Name                                                       | Version  |
|------------------------------------------------------------|----------|
| <a name="provider_google"></a> [google](#provider\_google) | \>= 6.12 |
| <a name="provider_random"></a> [random](#provider\_random) | \>= 3.6  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                  | Type        |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network)                      | data source |
| [google_sql_database_instance.primary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance)          | resource    |
| [google_sql_database_instance.replica](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance)          | resource    |
| [google_sql_database_instance.analytic_replica](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource    |
| [google_sql_database.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database.html)                          | resource    |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database.html)                                | resource    |
| [google_sql_user.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user)                                       | resource    |

## Inputs

| Name                                                                                                                                                     | Description                                                                                                                                                          | Type        | Default       | Required |
|----------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|---------------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                                                                                       | The ID of the project where the GKE will be created.                                                                                                                 | string      | n/a           |   yes    |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name)                                                                                 | The name of the network being created.                                                                                                                               | string      | n/a           |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                           | The prefix name of the Cloud SQL instance being created.                                                                                                             | string      | n/a           |   yes    |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name)                                                                                                | The name of database being created.                                                                                                                                  | string      | n/a           |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                                                                     | The GCP Region to use for deployment.                                                                                                                                | string      | n/a           |   yes    |
| <a name="input_size"></a> [size](#input\_size)                                                                                                           | Start size in GB.                                                                                                                                                    | number      | n/a           |   yes    |
| <a name="input_tier"></a> [tier](#input\_tier)                                                                                                           | Database tier.                                                                                                                                                       | string      | `db-f1-micro` |    no    |
| <a name="input_username"></a> [username](#input\_username)                                                                                               | The database username to get access.                                                                                                                                 | string      | n/a           |   yes    |
| <a name="input_password"></a> [password](#input\_password)                                                                                               | The database password to get access.                                                                                                                                 | string      | `null`        |    no    |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type)                                                                  | The availability type of the Cloud SQL instance, high availability (REGIONAL) or single zone (ZONAL).                                                                | string      | `ZONAL`       |    no    |
| <a name="input_replica_count"></a> [replica_count](#input\_replica\_count)                                                                               | The number of Cloud SQL replicas to create.                                                                                                                          | number      | 0             |    no    |
| <a name="input_analytic_replica_count"></a> [analytic\_replica\_count](#input\_analytic\_replica\_count)                                                 |                                                                                                                                                                      | number      | 0             |    no    |
| <a name="input_labels"></a> [labels](#input\_labels)                                                                                                     | The resource labels to represent user provided metadata.                                                                                                             | map(string) | {}            |    no    |
| <a name="input_database_flags"></a> [database\_flags](#input\_database\_flags)                                                                           | The Cloud SQL instance database flags to create.                                                                                                                     | map(string) | {}            |    no    |
| <a name="input_enabled_deletion_protection"></a> [enabled\_deletion\_protection](#input\_enabled\_deletion\_protection)                                  | The boolean to specifies whether deletion protection should be enabled of disabled.                                                                                  | bool        | `true`        |    no    |
| <a name="input_daily_sql_instance_backup_start_time"></a> [daily\_sql\_instance\_backup\_start\_time](#input\_daily\_sql\_instance\_backup\_start\_time) | The start time of daily Cloud SQL instance backup in format 'HH:MM' 24-hour UTC.                                                                                     | string      | `08:00`       |    no    |
| <a name="input_retained_backups_count"></a> [retained\_backups\_count](#input\_retained\_backups\_count)                                                 | Depending on the value of retention_unit, this is used to determine if a backup needs to be deleted. If retention_unit is 'COUNT', we will retain this many backups. | number      | `7`           |    no    |
| <a name="input_transaction_log_retention_days"></a> [transaction\_log\_retention\_days](#input\_transaction\_log\_retention\_days)                       | The number of days of transaction logs we retain for point in time restore, from 1-7 for standard instance.                                                          | number      | `7`           |    no    |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version)                                                                     | The Cloud SQL database version to use.                                                                                                                               | string      | `POSTGRES_16` |    no    |
| <a name="input_enabled_disk_autoresize"></a> [enabled\_disk\_autoresize](#input\_enabled\_disk\_autoresize)                                              | Enables auto-resizing of the storage size. Defaults to true.                                                                                                         | bool        | `true`        |    no    |

## Outputs

| Name                                                                                                                                                                   | Description                                                                                                                |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
| <a name="output_db_primary_private_ip_address"></a> [db\_primary\_private\_ip\_address](#output\_db\_primary\_private\_ip\_address)                                    | The private IP address of primary instance.                                                                                |
| <a name="output_db_replica_private_ip_address"></a> [db\_replica\_private\_ip\_address](#output\_db\_replica\_private\_ip\_address)                                    | The list of private IP address of replica instance. If there is no replica, use the primary instance's private IP address. |
| <a name="output_db_analytic_replica_private_ip_addresses"></a> [db\_analytic\_replica\_private\_ip\_addresses](#output\_db\_analytic\_replica\_private\_ip\_addresses) | The list of private IP address of analytic replica instance.                                                               |
| <a name="output_db_primary_connection_name"></a> [db\_primary\_connection\_name](#output\_db\_primary\_connection\_name)                                               | The primary instance connection name.                                                                                      |
| <a name="output_db_replica_connection_name"></a> [db\_replica\_connection\_name](#output\_db\_replica\_connection\_name)                                               | The list of replica(s) connection name.                                                                                    |
| <a name="output_db_analytic_replica_connection_name"></a> [db\_analytic\_replica\_connection\_name](#output\_db\_analytic\_replica\_connection\_name)                  | The list of analytic replica(s) connection name.                                                                           |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username)                                                                                                | The database username.                                                                                                     |
| <a name="output_db_password"></a> [db\_password](#output\_db\_password)                                                                                                | The database password.                                                                                                     |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name)                                                                                                            | The database name.                                                                                                         |

<!-- END_TF_DOCS -->
