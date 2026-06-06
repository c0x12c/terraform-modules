# Datadog RBAC sub-module

Terraform Datadog RBAC sub-module.

## Usage

### Create Datadog RBAC

```hcl
module "datadog_rbac" {
  source  = "c0x12c/eks-datadog-rbac/aws"

  fargate_profiles        = var.fargate_profiles
  default_service_account = var.default_service_account
  custom_namespaces       = var.custom_namespaces
}
```

## Examples

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.33.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role.datadog_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding_v1.datadog_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_datadog_agent_cluster_role"></a> [create\_datadog\_agent\_cluster\_role](#input\_create\_datadog\_agent\_cluster\_role) | Controls whether to create the Datadog Agent ClusterRole | `bool` | `true` | no |
| <a name="input_custom_service_accounts"></a> [custom\_service\_accounts](#input\_custom\_service\_accounts) | Map of service account names for binding with Datadog.<br/>Each key represents a namespace, and the value is a list of service account names.<br/>  {<br/>    namespace = ["service-account1", "service-account2]<br/>  } | `map(list(string))` | `{}` | no |
| <a name="input_datadog_agent_cluster_role_name"></a> [datadog\_agent\_cluster\_role\_name](#input\_datadog\_agent\_cluster\_role\_name) | Name of the ClusterRole to create in order to configure Datadog Agents | `string` | n/a | yes |
| <a name="input_default_service_account"></a> [default\_service\_account](#input\_default\_service\_account) | Default service account name for binding with Datadog | `string` | `"default"` | no |
| <a name="input_enable_default_service_accounts"></a> [enable\_default\_service\_accounts](#input\_enable\_default\_service\_accounts) | Enable or disable binding of default service accounts | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
