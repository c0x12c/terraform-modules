# Basic Reloader Example

This example shows the most basic configuration for deploying Reloader.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What this creates

- Reloader deployed in the `reloader-system` namespace
- RBAC resources (ClusterRole, ClusterRoleBinding, ServiceAccount)
- Default configuration with global watching enabled
- Uses the `env-vars` reload strategy
