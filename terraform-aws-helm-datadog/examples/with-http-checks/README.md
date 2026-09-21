# Example: with-http-checks

This example adds Datadog HTTP checks via `http_check_urls`. The check is rendered into a single `confd` file on the cluster agent (`enabled_cluster_check = true`), so it runs once as a cluster check rather than once per node.

Use it when you need uptime/health checks against a set of HTTP endpoints without deploying a separate synthetics agent.

## Requirements

An existing EKS cluster and Datadog API/app keys.

## Usage

```bash
terraform init
terraform plan
```
