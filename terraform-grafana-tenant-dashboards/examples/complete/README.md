# Grafana project dashboards

## Usage

Set `GRAFANA_URL` to your Grafana URL and `GRAFANA_AUTH` to a service account token
with permission to manage folders and dashboards. Enable nested folders in Grafana.
The example creates dev and prod folders with all six dashboard presets.

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 4.55 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tenant_dashboards"></a> [tenant\_dashboards](#module\_tenant\_dashboards) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
