# GitOps Reloader Example

This example shows a GitOps-friendly configuration for deploying Reloader with ArgoCD or Flux.

## GitOps Considerations

- **Annotations Strategy**: Uses the annotations reload strategy to prevent config drift in GitOps tools
- **JSON Logging**: Uses JSON format for better log aggregation and monitoring
- **Namespace Filtering**: Only watches production namespaces using label selectors
- **Minimal Resources**: Uses minimal resource allocation suitable for GitOps environments
- **Proper Labels**: Includes GitOps-specific labels for better resource management

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What this creates

- Reloader deployed in the `reloader-system` namespace
- Annotations-based reload strategy to prevent GitOps config drift
- Namespace filtering to only watch production environments
- JSON logging for better observability
- Minimal resource allocation
- GitOps-friendly labels and annotations

## Integration with ArgoCD

When using this configuration with ArgoCD, the annotations strategy ensures that:

1. Reloader doesn't modify pod specs in ways that cause ArgoCD sync conflicts
2. Rolling updates are triggered through annotations rather than environment variables
3. The deployment remains in sync with the Git repository

## Integration with Flux

This configuration works well with Flux v2 as it:

1. Uses annotations for reload triggers instead of environment variables
2. Maintains consistency with Flux's reconciliation model
3. Provides clear labeling for Flux to manage the resources
