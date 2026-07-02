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
  chart_version = "0.21.0"
  hostname      = "devlake.example.com"

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
