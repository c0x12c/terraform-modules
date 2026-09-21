# Example: ignore-auto-config

This example uses `ignore_auto_config` to stop the node agent from auto-scraping the cluster agent's own `/metrics` endpoint.

The node agent ships default Autodiscovery templates keyed on container images. When it sees a matching container on its node, such as the cluster agent, it schedules that integration without any config from you. Listing `"datadog_cluster_agent"` in `ignore_auto_config` renders `datadog.ignoreAutoConfig` in the Helm values, which sets `DD_IGNORE_AUTOCONF` on the node agent and skips that auto-detected check.

Other auto-configured integrations (for example `redisdb`, `postgres`) can be suppressed the same way by adding their integration name to the list.

To verify after apply, exec into a node agent pod and confirm the integration is no longer listed:

```bash
kubectl exec -it -n datadog <node-agent-pod> -- agent status
```

`datadog_cluster_agent` should not appear under the "Running Checks" section.

## Requirements

An existing EKS cluster and Datadog API/app keys.

## Usage

```bash
terraform init
terraform plan
```
