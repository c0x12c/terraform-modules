# Grafana project dashboards module

Terraform module which creates Grafana folders and preset dashboards for a project.

The module creates a parent folder named after `project`, a child folder for each
environment, and one dashboard per environment and enabled preset. The presets are
`pods`, `runtime`, `elasticache`, `rds`, `uptime`, and `red`. With dev and prod and
all presets enabled, this creates three folders and twelve dashboards.
Grafana must support nested folders and have them enabled.

Dashboard UIDs follow `<project>-<env>-<preset>`. Extra dashboards use their map
key in place of the preset. Each UID must be at most 40 characters; input
validation rejects longer values. Keep project and extra dashboard names short.
The default parent folder UID is `<project>` and child folder UIDs are
`<project>-<env>`.

## Usage

### Create Grafana project dashboards

Configure `GRAFANA_URL` and `GRAFANA_AUTH` for the Grafana provider. Use the local
module source below from an example directory; see [the complete example](examples/complete).

```hcl
provider "grafana" {}

module "tenant_dashboards" {
  source = "../../"

  project = "example"
  environments = {
    dev = {
      namespace    = "example-dev"
      service_name = "example-api"
      pod_regex    = "example-api-.*"
    }
    prod = {
      namespace    = "example-prod"
      service_name = "example-api"
      pod_regex    = "example-api-.*"
    }
  }

  red_thresholds = {
    p95_seconds = 1
    error_ratio = 0.05
  }
}
```

### Adopt existing folders

Set `folder_uids` to preserve existing folder UIDs, then import those folders
before applying. Supplying UIDs alone does not import remote resources into state.
The existing environment folders must be children of the selected parent.

```hcl
  folder_uids = {
    parent = "existing-project"
    envs = {
      dev  = "existing-dev"
      prod = "existing-prod"
    }
  }
```

For the module name above, import each existing folder:

```bash
terraform import 'module.tenant_dashboards.grafana_folder.parent' existing-project
terraform import 'module.tenant_dashboards.grafana_folder.env["dev"]' existing-dev
terraform import 'module.tenant_dashboards.grafana_folder.env["prod"]' existing-prod
```

### RED thresholds and dashboard customization

`red_thresholds.p95_seconds` sets the P95 latency threshold line in seconds
(default `1`). `red_thresholds.error_ratio` sets the 5xx error ratio threshold
line (default `0.05`, or 5 percent). These are dashboard threshold lines, not alert
rules. Both values apply to every environment's `red` dashboard.

Use `enabled_presets` to select presets, `dashboard_overrides` to replace titles
or disable dashboards, and `extra_dashboards` to render additional JSON dashboards
for every environment. Environment settings populate dashboard constants;
`aws_tag_project` defaults to `project` when omitted.

### Minimum interval

`min_interval` is the minimum query interval stamped on every panel with queries.
Set it to at least twice the longest scrape period of the series the dashboards
read, for example `"2m"` for series scraped every minute. Grafana's
`$__rate_interval` is derived from this value and the data source scrape interval,
and a `rate()` window shorter than two samples returns no data. It is stamped as the
panel `interval` and on every target of each panel that has targets, in presets and
`extra_dashboards`, including panels nested in rows. The default `null` leaves the
rendered JSON unchanged.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 4.55 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | ~> 4.55 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [grafana_dashboard.this](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_folder.env](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.parent](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dashboard_overrides"></a> [dashboard\_overrides](#input\_dashboard\_overrides) | Per-dashboard overrides keyed by preset or extra dashboard name. title replaces the generated title, enabled = false drops the dashboard. | <pre>map(object({<br/>    title   = optional(string)<br/>    enabled = optional(bool)<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled_presets"></a> [enabled\_presets](#input\_enabled\_presets) | Presets to render for every environment: pods, runtime, elasticache, rds, uptime, red. | `list(string)` | <pre>[<br/>  "pods",<br/>  "runtime",<br/>  "elasticache",<br/>  "rds",<br/>  "uptime",<br/>  "red"<br/>]</pre> | no |
| <a name="input_environments"></a> [environments](#input\_environments) | Environments keyed by dev or prod. Dashboard constants use namespace, service\_name, pod\_regex and container (default spartan); aws\_tag\_project defaults to project. | <pre>map(object({<br/>    namespace       = string<br/>    service_name    = string<br/>    pod_regex       = string<br/>    container       = optional(string, "spartan")<br/>    aws_tag_project = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_extra_dashboards"></a> [extra\_dashboards](#input\_extra\_dashboards) | Additional dashboards, name => dashboard JSON. Rendered for every environment like a preset. | `map(string)` | `{}` | no |
| <a name="input_folder_uids"></a> [folder\_uids](#input\_folder\_uids) | Existing folder uids to adopt instead of the generated ones: parent, and envs keyed by env. | <pre>object({<br/>    parent = optional(string)<br/>    envs   = optional(map(string))<br/>  })</pre> | `{}` | no |
| <a name="input_min_interval"></a> [min\_interval](#input\_min\_interval) | Minimum query interval stamped on every panel with queries. Set it to at least twice the longest scrape period of the series the dashboards read, for example 2m for series scraped every minute; Grafana's $\_\_rate\_interval is derived from this value and the data source scrape interval, and a rate() window shorter than two samples returns no data. Null leaves panels unchanged. | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name. Titles the parent folder and prefixes every dashboard uid. | `string` | n/a | yes |
| <a name="input_red_thresholds"></a> [red\_thresholds](#input\_red\_thresholds) | Threshold lines on the red preset: p95 latency in seconds and 5xx ratio (0.05 = 5 percent). | <pre>object({<br/>    p95_seconds = number<br/>    error_ratio = number<br/>  })</pre> | <pre>{<br/>  "error_ratio": 0.05,<br/>  "p95_seconds": 1<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard_uids"></a> [dashboard\_uids](#output\_dashboard\_uids) | Dashboard uid keyed by <env>/<preset>. |
| <a name="output_env_folder_uids"></a> [env\_folder\_uids](#output\_env\_folder\_uids) | Folder uid per environment. |
| <a name="output_parent_folder_uid"></a> [parent\_folder\_uid](#output\_parent\_folder\_uid) | Uid of the project parent folder. |
<!-- END_TF_DOCS -->
