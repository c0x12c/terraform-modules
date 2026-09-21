# Example: dedicated-nodes

This example pins both the node agent and the cluster agent to a tainted node group using `node_selector` and `tolerations`, for example a dedicated "backbone" or platform node pool.

Because `node_selector` is applied to the node agent DaemonSet, the agent then only runs on nodes matching the selector, not on every node in the cluster - keep that in mind if you also expect it to monitor workloads scheduled elsewhere.

Use it when Datadog itself must run on a specific node group (for licensing, isolation, or capacity reasons) rather than cluster-wide.

## Requirements

An existing EKS cluster with a tainted node group labeled `service-type=backbone`, and Datadog API/app keys.

## Usage

```bash
terraform init
terraform plan
```
