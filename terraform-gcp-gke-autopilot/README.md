# GKE Autopilot Cluster Terraform module

This Terraform module provisions a Google Kubernetes Engine (GKE) Autopilot cluster with configurable options.

## Usage

### Create GKE Autopilot Cluster

```hcl
module "gke_autopilot" {
  source  = "../modules/gcp/gke-autopilot"

  project_id                     = "my-gcp-project"
  region                         = "us-central1"
  environment                    = "production"
  network                        = "default"
  subnetwork                     = "default"
  enable_private_endpoint        = true
  enable_private_nodes           = true
  enable_vertical_pod_autoscaling = true
  master_ipv4_cidr_block         = "172.23.0.0/28"
  release_channel                = "STABLE"
  min_master_version             = "1.24.14-gke.2700"
  
  maintenance_start_time         = "2024-09-01T09:00:00Z"
  maintenance_end_time           = "2024-09-01T17:00:00Z"
  maintenance_recurrence         = "FREQ=WEEKLY;INTERVAL=2;BYDAY=WE"

  cluster_secondary_range_name   = "pods"
  services_secondary_range_name  = "services"

  master_authorized_networks_config = [
    {
      cidr_block   = "192.168.0.0/24"
      display_name = "Office Network"
    },
    {
      cidr_block   = "203.0.113.0/24"
      display_name = "Remote Office Network"
    }
  ]

  labels = {
    environment = "production"
    team        = "devops"
  }
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

## Modules

No modules.

## Resources

| Name                                                                                                                              | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------|----------|
| [google_container_cluster.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |

## Inputs

| Name                                                                                                                                                | Description                                                                                                                                                                                                                                                     | Type                                                                                   | Default                            | Required |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|------------------------------------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)                                                                            | The name of the GKE cluster will be created.                                                                                                                                                                                                                    | string                                                                                 | n/a                                |   yes    |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                                                                                  | The ID of the project where the GKE will be created.                                                                                                                                                                                                            | string                                                                                 | n/a                                |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                                                                | Region where the resources will be created.                                                                                                                                                                                                                     | string                                                                                 | n/a                                |   yes    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                                                 | Environment where the resources will be created.                                                                                                                                                                                                                | string                                                                                 | n/a                                |   yes    |
| <a name="input_network"></a> [network](#input\_network)                                                                                             | The name or self_link of the Google Compute Engine network to which the cluster is connected. For Shared VPC, set this to the self link of the shared network.                                                                                                  | string                                                                                 | n/a                                |   yes    |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork)                                                                                    | The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched.                                                                                                                                                    | string                                                                                 | n/a                                |   yes    |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint)                                         | When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used. This field only applies to private clusters, when enable_private_nodes is true.          | bool                                                                                   | `false`                            |    no    |
| <a name="input_enable_private_nodes"></a> [enable\_private\_nodes](#input\_enable\_private\_nodes)                                                  | Enables the private cluster feature, creating a private endpoint on the cluster. In a private cluster, nodes only have RFC 1918 private addresses and communicate with the master's private endpoint via private networking.                                    | bool                                                                                   | `true`                             |    no    |
| <a name="input_enable_vertical_pod_autoscaling"></a> [enable\_vertical\_pod\_autoscaling](#input\_enable\_vertical\_pod\_autoscaling)               | Enable vertical pod autoscaling controlled by the cluster.                                                                                                                                                                                                      | bool                                                                                   | `true`                             |    no    |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block)                                          | The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network. | string                                                                                 | `172.23.0.0/28`                    |    no    |
| <a name="input_master_authorized_networks_config"></a> [master\_authorized\_networks\_config](#input\_master\_authorized\_networks\_config)         | List of CIDR blocks to allow access to the Kubernetes master. External network that can access Kubernetes master through HTTPS. Must be specified in CIDR notation.                                                                                             | <pre>list(object({<br/>  cidr_block = string<br/>  display_name = string<br/>}))</pre> | `[]`                               |    no    |
| <a name="input_labels"></a> [labels](#input\_labels)                                                                                                | The resource labels to represent user provided metadata.                                                                                                                                                                                                        | map(string)                                                                            | `null`                             |    no    |
| <a name="input_daily_maintenance_window_start_time"></a> [daily\_maintenance\_window\_start\_time](#input\_daily\_maintenance\_window\_start\_time) | Time window specified for daily maintenance operations.                                                                                                                                                                                                         | string                                                                                 | `09:00`                            |    no    |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel)                                                                   | The selected [release channel](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#channel).                                                                                                                       | string                                                                                 | `STABLE`                           |    no    |
| <a name="input_min_master_version"></a> [min\_master\_version](#input\_min\_master\_version)                                                        | The minimum version of the master. GKE will auto-update the master to new versions, so this does not guarantee the current master version--use the read-only master_version field to obtain that.                                                               | string                                                                                 | `1.30.5-gke.1014003`               |    no    |
| <a name="input_maintenance_start_time"></a> [maintenance\_start\_time](#input\_maintenance\_start\_time)                                            | Start time for the maintenance window (format: `YYYY-MM-DDTHH:MM:SSZ`).                                                                                                                                                                                         | string                                                                                 | `2024-11-25T00:00:00Z`             |    no    |
| <a name="input_maintenance_end_time"></a> [maintenance\_end\_time](#input\_maintenance\_end\_time)                                                  | End time for the maintenance window (format: `YYYY-MM-DDTHH:MM:SSZ`).                                                                                                                                                                                           | string                                                                                 | `2024-11-25T04:00:00Z`             |    no    |
| <a name="input_maintenance_recurrence"></a> [maintenance\_recurrence](#input\_maintenance\_recurrence)                                              | Recurrence rule for maintenance. Occurs on weekdays.                                                                                                                                                                                                            | string                                                                                 | `FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR` |    no    |
| <a name="input_cluster_secondary_range_name"></a> [cluster\_secondary\_range\_name](#input\_cluster\_secondary\_range\_name)                        | The name of the secondary range to be used for the Kubernetes pods.                                                                                                                                                                                             | string                                                                                 | `pods`                             |    no    |
| <a name="input_services_secondary_range_name"></a> [services\_secondary\_range\_name](#input\_services\_secondary\_range\_name)                     | The name of the secondary range to be used for the Kubernetes services.                                                                                                                                                                                         | string                                                                                 | `services`                         |    no    |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection)                                                       | Whether or not to allow Terraform to destroy the cluster. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the cluster will fail.                                                                 | bool                                                                                   | `true`                             |    no    |
| <a name="input_enable_cost_management_config"></a> [enable\_cost\_management\_config](#input\_enable\_cost\_management\_config)                     | Whether or not to enable GCP Cost Allocation feature.                                                                                                                                                                                                           | bool                                                                                   | `false`                            |    no    |

## Outputs

| Name                                                                                        | Description                                                                                                 |
|---------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name)                  | The name of the cluster, unique within the project and location.                                            |
| <a name="ouput_cluster_id"></a> [cluster\_id](#output\_cluster\_id)                         | An identifier for the GKE resource with format `projects/{{project}}/locations/{{zone}}/clusters/{{name}}`. |
| <a name="output_cluster_self_link"></a> [cluster\_self\_link](#output\_cluster\_self\_link) | The server-defined URL for the GKE resource.                                                                |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint)                                | The IP address of this cluster's Kubernetes master.                                                         |
| <a name="output_master_auth"></a> [master\_auth](#output\_master\_auth)                     | Base64 encoded public certificate used by clients to authenticate to the cluster endpoint.                  |

<!-- END_TF_DOCS -->
