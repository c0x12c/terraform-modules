# Example: extra_confd

This example shows how to inject a custom cluster-agent confd file into the Datadog chart without modifying the module.

The sample uses an OpenMetrics-style config that points at `https://example.com/metrics`.

Use it when you need custom cluster checks such as OpenMetrics or `tcp_check`.

Run the usual Terraform workflow from this directory:

```bash
terraform init
terraform plan
```
