# terraform-aws-helm-devlake

Installs and configures Apache DevLake on an EKS cluster via its Helm chart.

[DevLake](https://devlake.apache.org/) ingests and normalizes software delivery
data to power engineering-health metrics.

The module wraps the `devlake` chart and deploys:

- **lake** — the backend collector/API
- **config-ui** — the configuration and connection UI
- **mysql** — in-cluster database (or point it at an external server)

Grafana (the dashboarding layer) is bundled with the chart but disabled by
default; enable it with `enable_grafana` when you are ready to build dashboards.

## Usage

```hcl
module "devlake" {
  source  = "terraform.c0x12c.com/c0x12c/helm-devlake/aws"
  version = "~> 0.1"

  namespace     = "devlake"
  chart_version = "1.0.2"
  hostname      = "devlake.example.com"

  enable_grafana         = true
  grafana_admin_password = var.devlake_grafana_admin_password

  ingress_class_name = "alb"
  ingress_annotations = {
    "alb.ingress.kubernetes.io/scheme"          = "internal"
    "alb.ingress.kubernetes.io/group.name"      = "internal"
    "alb.ingress.kubernetes.io/target-type"     = "ip"
    "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:...:certificate/..."
    "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\": 443}]"
    "alb.ingress.kubernetes.io/healthcheck-path" = "/health/"
  }

  encryption_secret   = var.devlake_encryption_secret
  mysql_password      = var.devlake_mysql_password
  mysql_root_password = var.devlake_mysql_root_password
}
```

## Accessing and managing the instance

- The UI is reachable at `https://<hostname>` once the Ingress is provisioned.
  With an `internal` ALB scheme the host is only routable from inside the VPC
  (e.g. over VPN).
- `config-ui` proxies `/api` to the lake backend and `/grafana` to Grafana
  (when enabled), so a single hostname serves everything.
- Data lives in the in-cluster MySQL PVC (`mysql_storage_size`). Deleting the
  release does not delete the PVC.
- To rotate the encryption key or DB credentials, update the corresponding
  variables and re-apply. Changing `encryption_secret` after data has been
  collected makes existing encrypted connection details unreadable.

## Examples

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.2.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.devlake](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_name"></a> [chart\_name](#input\_chart\_name) | Helm chart name. | `string` | `"devlake"` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | Helm repository hosting the DevLake chart. | `string` | `"https://apache.github.io/devlake-helm-chart"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the apache/devlake Helm chart. | `string` | n/a | yes |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether this module creates the namespace. Set false if it already exists. | `bool` | `true` | no |
| <a name="input_enable_grafana"></a> [enable\_grafana](#input\_enable\_grafana) | Deploy the bundled Grafana dashboard component. | `bool` | `false` | no |
| <a name="input_encryption_secret"></a> [encryption\_secret](#input\_encryption\_secret) | DevLake ENCRYPTION\_SECRET. If empty, the chart auto-generates one. | `string` | `""` | no |
| <a name="input_grafana_admin_password"></a> [grafana\_admin\_password](#input\_grafana\_admin\_password) | Admin password for the bundled Grafana. Empty leaves the chart default. | `string` | `""` | no |
| <a name="input_helm_release_timeout"></a> [helm\_release\_timeout](#input\_helm\_release\_timeout) | Timeout in seconds for the Helm release. | `number` | `600` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname the DevLake UI is served on. Required when ingress is enabled. | `string` | `""` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Image tag applied to the DevLake components. Empty uses the chart's default (matching the chart version). | `string` | `""` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Annotations applied to the Ingress resource (controller-specific). | `map(string)` | `{}` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | IngressClass name (e.g. `alb` for the AWS Load Balancer Controller). | `string` | `"alb"` | no |
| <a name="input_ingress_enabled"></a> [ingress\_enabled](#input\_ingress\_enabled) | Expose DevLake through an Ingress resource. | `bool` | `true` | no |
| <a name="input_lake_replica_count"></a> [lake\_replica\_count](#input\_lake\_replica\_count) | Replica count for the lake (backend) deployment. | `number` | `1` | no |
| <a name="input_lake_resources"></a> [lake\_resources](#input\_lake\_resources) | Resource requests/limits for the lake (backend) container. | `any` | <pre>{<br/>  "limits": {<br/>    "cpu": "1",<br/>    "memory": "1Gi"<br/>  },<br/>  "requests": {<br/>    "cpu": "250m",<br/>    "memory": "512Mi"<br/>  }<br/>}</pre> | no |
| <a name="input_mysql_database"></a> [mysql\_database](#input\_mysql\_database) | Database name for DevLake. | `string` | `"lake"` | no |
| <a name="input_mysql_external_port"></a> [mysql\_external\_port](#input\_mysql\_external\_port) | External MySQL port. Only used when mysql\_use\_external is true. | `number` | `3306` | no |
| <a name="input_mysql_external_server"></a> [mysql\_external\_server](#input\_mysql\_external\_server) | External MySQL host. Only used when mysql\_use\_external is true. | `string` | `"127.0.0.1"` | no |
| <a name="input_mysql_password"></a> [mysql\_password](#input\_mysql\_password) | Password for the DevLake database user. | `string` | `""` | no |
| <a name="input_mysql_resources"></a> [mysql\_resources](#input\_mysql\_resources) | Resource requests/limits for the in-cluster MySQL container. | `any` | <pre>{<br/>  "limits": {<br/>    "cpu": "1",<br/>    "memory": "1Gi"<br/>  },<br/>  "requests": {<br/>    "cpu": "250m",<br/>    "memory": "512Mi"<br/>  }<br/>}</pre> | no |
| <a name="input_mysql_root_password"></a> [mysql\_root\_password](#input\_mysql\_root\_password) | Root password for the in-cluster MySQL instance. | `string` | `""` | no |
| <a name="input_mysql_storage_class"></a> [mysql\_storage\_class](#input\_mysql\_storage\_class) | Storage class for the in-cluster MySQL PVC. Empty uses the cluster default. | `string` | `""` | no |
| <a name="input_mysql_storage_size"></a> [mysql\_storage\_size](#input\_mysql\_storage\_size) | Persistent volume size for the in-cluster MySQL instance. | `string` | `"20Gi"` | no |
| <a name="input_mysql_use_external"></a> [mysql\_use\_external](#input\_mysql\_use\_external) | Use an external MySQL server instead of the bundled in-cluster instance. | `bool` | `false` | no |
| <a name="input_mysql_username"></a> [mysql\_username](#input\_mysql\_username) | Username for the DevLake database. | `string` | `"merico"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace to deploy DevLake into. Created by this module. | `string` | `"devlake"` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Helm release name. | `string` | `"devlake"` | no |
| <a name="input_ui_replica_count"></a> [ui\_replica\_count](#input\_ui\_replica\_count) | Replica count for the config-ui deployment. | `number` | `1` | no |
| <a name="input_ui_resources"></a> [ui\_resources](#input\_ui\_resources) | Resource requests/limits for the config-ui container. | `any` | <pre>{<br/>  "limits": {<br/>    "cpu": "500m",<br/>    "memory": "256Mi"<br/>  },<br/>  "requests": {<br/>    "cpu": "100m",<br/>    "memory": "128Mi"<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Deployed DevLake chart version. |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Hostname the DevLake UI is served on. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace DevLake is deployed into. |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Name of the Helm release. |
<!-- END_TF_DOCS -->
