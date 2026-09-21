# Example: with-log-collection

This example turns on log collection from the node agent (`enabled_logs`, `enabled_container_collect_all_logs`) and uses `container_exclude` to drop noisy namespaces (here, `kube-system` and pause containers) from collection.

Container log collection bills per log event ingested by Datadog. Excluding system/infra noise up front keeps log volume, and cost, proportional to the logs you actually want to search.

Use it when you need application log collection and want to control what gets shipped from day one.

## Requirements

An existing EKS cluster and Datadog API/app keys.

## Usage

```bash
terraform init
terraform plan
```
