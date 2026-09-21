# Example: minimal

This example sets only the required inputs (`environment`, `cluster_name`, `datadog_site`, `datadog_api_key`, `datadog_app_key`) and leaves everything else at its module default.

With the defaults you get:

- the node agent DaemonSet disabled (`enabled_agent` defaults to `false`)
- the cluster agent enabled, with the metrics provider and cluster checks enabled
- logs and container log collection enabled (they have no effect until the node agent is turned on)
- the bundled datadog-operator subchart disabled (`enable_operator` defaults to `false`)
- no http checks, no extra confd files, no ignored auto-config integrations
- release name `datadog` in namespace `datadog`

Use this as a starting point when you only need the cluster agent (for example, metrics provider / cluster checks) and will enable the node agent separately once you are ready for log/metric collection from every node.

## Requirements

An existing EKS cluster and Datadog API/app keys.

## Usage

```bash
terraform init
terraform plan
```
