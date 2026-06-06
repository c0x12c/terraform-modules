# Terraform Kubernetes Helm Reloader Module

This Terraform module deploys [Stakater Reloader](https://github.com/stakater/Reloader) to a Kubernetes cluster using Helm. Reloader is a Kubernetes controller that watches changes in ConfigMaps and Secrets and performs rolling upgrades on Pods with their associated Deployment, StatefulSet, DaemonSet and DeploymentConfig.

## Features

- Deploys Reloader using the official Stakater Helm chart
- Creates namespace with custom labels and annotations
- Support for all Reloader configuration options
- Flexible resource filtering and namespace selection
- Customizable annotation key overrides
- Security context configuration
- Resource limits and requests
- Node selector, tolerations, and affinity support

## Usage

### Basic Usage

```hcl
module "reloader" {
  source = "github.com/spartan-stratos/terraform-modules//kubernetes/helm/reloader?ref=v1.0.0"

  namespace = "reloader-system"
}
```

### Advanced Usage

```hcl
module "reloader" {
  source = "github.com/spartan-stratos/terraform-modules//kubernetes/helm/reloader?ref=v1.0.0"

  namespace = "reloader-system"
  
  # Reloader Configuration
  watch_globally = true
  reload_strategy = "annotations"  # Use annotations strategy for GitOps
  log_level = "info"
  log_format = "json"
  
  # Resource Filtering
  resources_to_ignore = "configmaps"  # Ignore ConfigMaps, only watch Secrets
  ignored_workload_types = "jobs,cronjobs"
  namespaces_to_ignore = "kube-system,kube-public"
  
  # Resource Configuration
  replica_count = 2
  resources = {
    requests = {
      cpu = "50m"
      memory = "64Mi"
    }
    limits = {
      cpu = "200m"
      memory = "256Mi"
    }
  }
  
  # Node Selection
  node_selector = {
    "node-role.kubernetes.io/worker" = "true"
  }
  
  # Tolerations
  tolerations = [
    {
      key = "node-role.kubernetes.io/control-plane"
      operator = "Exists"
      effect = "NoSchedule"
    }
  ]
  
  # Security Context
  security_context = {
    run_as_non_root = true
    run_as_user = 65534
    run_as_group = 65534
    fs_group = 65534
  }
  
  # Labels
  labels = {
    "app.kubernetes.io/part-of" = "platform"
    "environment" = "production"
  }
}
```

### GitOps-friendly Configuration

For GitOps environments like ArgoCD, use the annotations strategy to avoid config drift:

```hcl
module "reloader" {
  source = "github.com/spartan-stratos/terraform-modules//kubernetes/helm/reloader?ref=v1.0.0"

  namespace = "reloader-system"
  reload_strategy = "annotations"
  log_format = "json"
  
  # Only watch specific namespaces
  watch_globally = false
  namespace_selector = "environment=production"
}
```

## Examples

- [Basic Example](./examples/basic)
- [Advanced Example](./examples/advanced)
- [GitOps Example](./examples/gitops)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.16.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.16.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.33.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_values"></a> [additional\_values](#input\_additional\_values) | Additional values to pass to the Helm chart | `list(string)` | `[]` | no |
| <a name="input_affinity"></a> [affinity](#input\_affinity) | Affinity rules for Reloader pods | `any` | `{}` | no |
| <a name="input_auto_reload_all"></a> [auto\_reload\_all](#input\_auto\_reload\_all) | Whether to auto-reload all resources | `bool` | `false` | no |
| <a name="input_auto_annotation"></a> [auto\_annotation](#input\_auto\_annotation) | Override reloader.stakater.com/auto annotation key | `string` | `null` | no |
| <a name="input_auto_search_annotation"></a> [auto\_search\_annotation](#input\_auto\_search\_annotation) | Override reloader.stakater.com/search annotation key | `string` | `null` | no |
| <a name="input_chart_url"></a> [chart\_url](#input\_chart\_url) | URL of the Reloader Helm chart repository | `string` | `"https://stakater.github.io/stakater-charts"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the Reloader Helm chart | `string` | `"1.4.8"` | no |
| <a name="input_configmap_annotation"></a> [configmap\_annotation](#input\_configmap\_annotation) | Override configmap.reloader.stakater.com/reload annotation key | `string` | `null` | no |
| <a name="input_configmap_auto_annotation"></a> [configmap\_auto\_annotation](#input\_configmap\_auto\_annotation) | Override configmap.reloader.stakater.com/auto annotation key | `string` | `null` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether to create the namespace | `bool` | `true` | no |
| <a name="input_create_rbac"></a> [create\_rbac](#input\_create\_rbac) | Whether to create RBAC resources | `bool` | `true` | no |
| <a name="input_enable_ha"></a> [enable\_ha](#input\_enable\_ha) | Whether to enable high availability (leadership election) | `bool` | `false` | no |
| <a name="input_enable_metrics_by_namespace"></a> [enable\_metrics\_by\_namespace](#input\_enable\_metrics\_by\_namespace) | Whether to expose prometheus counter of reloads by namespace | `bool` | `false` | no |
| <a name="input_enable_pprof"></a> [enable\_pprof](#input\_enable\_pprof) | Enable pprof for profiling | `bool` | `false` | no |
| <a name="input_ignored_workload_types"></a> [ignored\_workload\_types](#input\_ignored\_workload\_types) | Comma-separated list of workload types to ignore (jobs, cronjobs) | `string` | `null` | no |
| <a name="input_ignore_configmaps"></a> [ignore\_configmaps](#input\_ignore\_configmaps) | Whether to ignore configmaps | `bool` | `false` | no |
| <a name="input_ignore_cronjobs"></a> [ignore\_cronjobs](#input\_ignore\_cronjobs) | Whether to ignore CronJob workloads | `bool` | `false` | no |
| <a name="input_ignore_jobs"></a> [ignore\_jobs](#input\_ignore\_jobs) | Whether to ignore Job workloads | `bool` | `false` | no |
| <a name="input_ignore_secrets"></a> [ignore\_secrets](#input\_ignore\_secrets) | Whether to ignore secrets | `bool` | `false` | no |
| <a name="input_is_argo_rollouts"></a> [is\_argo\_rollouts](#input\_is\_argo\_rollouts) | Whether this is an Argo Rollouts deployment | `bool` | `false` | no |
| <a name="input_is_openshift"></a> [is\_openshift](#input\_is\_openshift) | Whether this is an OpenShift deployment | `bool` | `false` | no |
| <a name="input_image_pull_policy"></a> [image\_pull\_policy](#input\_image\_pull\_policy) | Image pull policy | `string` | `"IfNotPresent"` | no |
| <a name="input_image_repository"></a> [image\_repository](#input\_image\_repository) | Reloader image repository | `string` | `"ghcr.io/stakater/reloader"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Reloader image tag | `string` | `"v1.4.8"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_log_format"></a> [log\_format](#input\_log\_format) | Log format (text or json) | `string` | `"text"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for Reloader (trace, debug, info, warning, error, fatal, panic) | `string` | `"info"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to install Reloader | `string` | `"reloader-system"` | no |
| <a name="input_namespace_annotations"></a> [namespace\_annotations](#input\_namespace\_annotations) | Annotations to apply to the namespace | `map(string)` | `{}` | no |
| <a name="input_namespace_labels"></a> [namespace\_labels](#input\_namespace\_labels) | Labels to apply to the namespace | `map(string)` | `{}` | no |
| <a name="input_namespace_selector"></a> [namespace\_selector](#input\_namespace\_selector) | Label selector to filter namespaces | `string` | `null` | no |
| <a name="input_namespaces_to_ignore"></a> [namespaces\_to\_ignore](#input\_namespaces\_to\_ignore) | Comma-separated list of namespaces to ignore | `string` | `null` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Node selector for Reloader pods | `map(string)` | `{}` | no |
| <a name="input_pause_deployment_annotation"></a> [pause\_deployment\_annotation](#input\_pause\_deployment\_annotation) | Override deployment.reloader.stakater.com/pause-period annotation key | `string` | `null` | no |
| <a name="input_pause_deployment_time_annotation"></a> [pause\_deployment\_time\_annotation](#input\_pause\_deployment\_time\_annotation) | Override deployment.reloader.stakater.com/paused-at annotation key | `string` | `null` | no |
| <a name="input_pod_security_context"></a> [pod\_security\_context](#input\_pod\_security\_context) | Pod security context for Reloader pods | <pre>object({<br/>    run_as_non_root = optional(bool, true)<br/>    run_as_user     = optional(number, 65534)<br/>    run_as_group    = optional(number, 65534)<br/>    fs_group        = optional(number, 65534)<br/>  })</pre> | `{}` | no |
| <a name="input_pprof_addr"></a> [pprof\_addr](#input\_pprof\_addr) | Address to start pprof server on | `string` | `":6060"` | no |
| <a name="input_read_only_root_filesystem"></a> [read\_only\_root\_filesystem](#input\_read\_only\_root\_filesystem) | Whether to use read-only root filesystem | `bool` | `false` | no |
| <a name="input_reload_on_create"></a> [reload\_on\_create](#input\_reload\_on\_create) | Whether to reload on create | `bool` | `false` | no |
| <a name="input_reload_on_delete"></a> [reload\_on\_delete](#input\_reload\_on\_delete) | Whether to reload on delete | `bool` | `false` | no |
| <a name="input_reload_strategy"></a> [reload\_strategy](#input\_reload\_strategy) | Strategy for triggering rolling updates (default, env-vars or annotations) | `string` | `"default"` | no |
| <a name="input_sync_after_restart"></a> [sync\_after\_restart](#input\_sync\_after\_restart) | Whether to sync after restart | `bool` | `false` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Name of the Helm release | `string` | `"reloader"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of Reloader replicas | `number` | `1` | no |
| <a name="input_resource_label_selector"></a> [resource\_label\_selector](#input\_resource\_label\_selector) | Label selector to filter ConfigMaps/Secrets | `string` | `null` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Resource requests and limits for Reloader | <pre>object({<br/>    requests = optional(object({<br/>      cpu    = optional(string, "10m")<br/>      memory = optional(string, "32Mi")<br/>    }), {})<br/>    limits = optional(object({<br/>      cpu    = optional(string, "100m")<br/>      memory = optional(string, "128Mi")<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_resources_to_ignore"></a> [resources\_to\_ignore](#input\_resources\_to\_ignore) | Resources to ignore (configmaps or secrets) | `string` | `null` | no |
| <a name="input_search_match_annotation"></a> [search\_match\_annotation](#input\_search\_match\_annotation) | Override reloader.stakater.com/match annotation key | `string` | `null` | no |
| <a name="input_secret_annotation"></a> [secret\_annotation](#input\_secret\_annotation) | Override secret.reloader.stakater.com/reload annotation key | `string` | `null` | no |
| <a name="input_secret_auto_annotation"></a> [secret\_auto\_annotation](#input\_secret\_auto\_annotation) | Override secret.reloader.stakater.com/auto annotation key | `string` | `null` | no |
| <a name="input_security_context"></a> [security\_context](#input\_security\_context) | Security context for Reloader pods | <pre>object({<br/>    run_as_non_root = optional(bool, true)<br/>    run_as_user     = optional(number, 65534)<br/>    run_as_group    = optional(number, 65534)<br/>    fs_group        = optional(number, 65534)<br/>  })</pre> | `{}` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | Tolerations for Reloader pods | <pre>list(object({<br/>    key      = string<br/>    operator = string<br/>    value    = optional(string)<br/>    effect   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_watch_globally"></a> [watch\_globally](#input\_watch\_globally) | Whether to watch all namespaces globally | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_release_name"></a> [helm\_release\_name](#output\_helm\_release\_name) | Name of the Helm release |
| <a name="output_helm_release_namespace"></a> [helm\_release\_namespace](#output\_helm\_release\_namespace) | Namespace where Reloader is deployed |
| <a name="output_helm_release_status"></a> [helm\_release\_status](#output\_helm\_release\_status) | Status of the Helm release |
| <a name="output_helm_release_version"></a> [helm\_release\_version](#output\_helm\_release\_version) | Version of the Helm release |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | Name of the namespace where Reloader is deployed |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | Name of the service account (managed by Helm chart) |

## Reloader Configuration

### Reload Strategies

Reloader supports three strategies for triggering rolling updates:

- **default**: Uses the default reload strategy (recommended for most use cases)
- **env-vars**: Adds a dummy environment variable to containers referencing the changed resource
- **annotations**: Adds a reloader.stakater.com/last-reloaded-from annotation to the pod template metadata

The `annotations` strategy is recommended for GitOps environments to prevent config drift.

### Resource Filtering

You can configure Reloader to:

- Ignore specific resource types (`configmaps` or `secrets`)
- Ignore specific workload types (`jobs`, `cronjobs`)
- Filter resources by labels
- Filter namespaces by labels
- Ignore specific namespaces

### Annotation Usage

To enable Reloader for a specific workload, add one of these annotations:

```yaml
# Auto-reload when any ConfigMap/Secret changes
reloader.stakater.com/auto: "true"

# Reload when specific ConfigMap changes
configmap.reloader.stakater.com/reload: "my-configmap"

# Reload when specific Secret changes
secret.reloader.stakater.com/reload: "my-secret"

# Search for ConfigMaps/Secrets with specific names
reloader.stakater.com/search: "true"
reloader.stakater.com/match: "my-app-*"
```

## License

This module is released under the Apache 2.0 License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Support

For support and questions:

- Create an issue in this repository
- Check the [Reloader documentation](https://docs.stakater.com/reloader/)
- Join the [Stakater Slack community](https://stakater.com/community.html)
