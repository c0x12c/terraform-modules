# Advanced Reloader Example

This example shows an advanced configuration for deploying Reloader in a production environment.

## Features

- **Annotations Strategy**: Uses the annotations reload strategy, ideal for GitOps environments
- **Resource Filtering**: Only watches Secrets (ignores ConfigMaps) and ignores Jobs/CronJobs
- **Namespace Filtering**: Ignores system namespaces
- **High Availability**: Deploys 2 replicas for redundancy
- **Resource Limits**: Sets appropriate CPU and memory limits
- **Node Selection**: Deploys only on worker nodes
- **Security**: Runs as non-root user with proper security context
- **Monitoring**: Uses JSON logging format for better observability

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What this creates

- Reloader deployed in the `reloader-system` namespace with 2 replicas
- RBAC resources with proper permissions
- Resource filtering to only watch Secrets in non-system namespaces
- Annotations-based reload strategy for GitOps compatibility
- Proper resource limits and security context
- Node selector to ensure deployment on worker nodes only
