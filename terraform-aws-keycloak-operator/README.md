# terraform-aws-keycloak-operator

Terraform module for deploying Keycloak using the official **Keycloak Operator** on AWS EKS.

## Why Keycloak Operator?

This module uses the official Keycloak Operator instead of Helm charts because:

| Aspect | Bitnami Helm (Previous) | Keycloak Operator (This Module) |
|--------|-------------------------|--------------------------------|
| **Cost** | Commercial subscription required | Free (open source) |
| **Image** | `bitnami/keycloak` | `quay.io/keycloak/keycloak` (official) |
| **Lifecycle** | Manual | Automated (self-healing, reconciliation) |
| **HA** | Manual configuration | Built-in (topology spread) |
| **Upgrades** | Manual | Declarative, smoother Day-2 ops |
| **GitOps** | Helm values | Native CRDs (Keycloak, KeycloakRealmImport) |

## Prerequisites

### OLM Installation (Recommended)

For the default OLM-based installation, you need [Operator Lifecycle Manager](https://olm.operatorframework.io/) on your cluster:

```bash
# Install OLM on vanilla Kubernetes
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.28.0/install.sh | bash -s v0.28.0
```

For OpenShift clusters, OLM is pre-installed.

### External PostgreSQL Database

This module requires an external PostgreSQL database (e.g., AWS RDS). Embedded databases are not supported for production use.

## Usage

### Basic Example (OLM Installation)

```hcl
# Create database credentials secret
resource "kubernetes_secret" "keycloak_db" {
  metadata {
    name      = "keycloak-db-credentials"
    namespace = "keycloak"
  }
  data = {
    username = "keycloak"
    password = var.db_password
  }
}

module "keycloak" {
  source  = "terraform.c0x12c.com/c0x12c/keycloak-operator/aws"
  version = "0.1.0"

  name      = "keycloak"
  namespace = "keycloak"
  hostname  = "keycloak.example.com"

  # Operator (OLM - recommended)
  install_operator        = true
  operator_install_method = "olm"

  # Database (external PostgreSQL)
  db_host = "keycloak-db.xxxxx.us-west-2.rds.amazonaws.com"
  db_username_secret = {
    name = kubernetes_secret.keycloak_db.metadata[0].name
    key  = "username"
  }
  db_password_secret = {
    name = kubernetes_secret.keycloak_db.metadata[0].name
    key  = "password"
  }

  # HA
  keycloak_instances = 2

  # AWS ALB Ingress
  create_ingress = true
}
```

### Manifest Installation (Without OLM)

For clusters without OLM, use the manifest installation method:

```hcl
module "keycloak" {
  source  = "terraform.c0x12c.com/c0x12c/keycloak-operator/aws"
  version = "0.1.0"

  # ... other configuration ...

  install_operator        = true
  operator_install_method = "manifest"  # Direct CRD installation
  operator_version        = "26.0.7"
}
```

### With Realm Import

```hcl
module "keycloak" {
  source  = "terraform.c0x12c.com/c0x12c/keycloak-operator/aws"
  version = "0.1.0"

  # ... other configuration ...

  realm_imports = {
    "production" = {
      realm   = "production"
      enabled = true
      clients = [
        {
          clientId     = "web-app"
          enabled      = true
          publicClient = true
          redirectUris = ["https://app.example.com/*"]
        }
      ]
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.25.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.25.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_ingress_v1.keycloak](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_manifest.keycloak](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.keycloak_crd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.operator_group](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.operator_subscription](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.realm_import](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.realm_import_crd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace_v1.keycloak](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_options"></a> [additional\_options](#input\_additional\_options) | Additional Keycloak server options (key-value pairs) | `map(string)` | `{}` | no |
| <a name="input_create_ingress"></a> [create\_ingress](#input\_create\_ingress) | Create AWS ALB Ingress for Keycloak | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it doesn't exist | `bool` | `true` | no |
| <a name="input_create_operator_namespace"></a> [create\_operator\_namespace](#input\_create\_operator\_namespace) | Create the operator namespace if it doesn't exist | `bool` | `true` | no |
| <a name="input_db_host"></a> [db\_host](#input\_db\_host) | PostgreSQL database host | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | PostgreSQL database name | `string` | `"keycloak"` | no |
| <a name="input_db_password_secret"></a> [db\_password\_secret](#input\_db\_password\_secret) | Kubernetes secret reference for database password | <pre>object({<br/>    name = string<br/>    key  = string<br/>  })</pre> | n/a | yes |
| <a name="input_db_pool_initial_size"></a> [db\_pool\_initial\_size](#input\_db\_pool\_initial\_size) | Initial database connection pool size | `number` | `5` | no |
| <a name="input_db_pool_max_size"></a> [db\_pool\_max\_size](#input\_db\_pool\_max\_size) | Maximum database connection pool size | `number` | `20` | no |
| <a name="input_db_pool_min_size"></a> [db\_pool\_min\_size](#input\_db\_pool\_min\_size) | Minimum database connection pool size | `number` | `5` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | PostgreSQL database port | `number` | `5432` | no |
| <a name="input_db_schema"></a> [db\_schema](#input\_db\_schema) | PostgreSQL database schema | `string` | `"public"` | no |
| <a name="input_db_username_secret"></a> [db\_username\_secret](#input\_db\_username\_secret) | Kubernetes secret reference for database username | <pre>object({<br/>    name = string<br/>    key  = string<br/>  })</pre> | n/a | yes |
| <a name="input_features_disabled"></a> [features\_disabled](#input\_features\_disabled) | List of Keycloak features to disable | `list(string)` | `[]` | no |
| <a name="input_features_enabled"></a> [features\_enabled](#input\_features\_enabled) | List of Keycloak features to enable | `list(string)` | `[]` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Keycloak hostname (required) | `string` | n/a | yes |
| <a name="input_hostname_admin"></a> [hostname\_admin](#input\_hostname\_admin) | Separate admin console hostname (optional) | `string` | `null` | no |
| <a name="input_hostname_strict"></a> [hostname\_strict](#input\_hostname\_strict) | Enable strict hostname validation | `bool` | `true` | no |
| <a name="input_hostname_strict_backchannel"></a> [hostname\_strict\_backchannel](#input\_hostname\_strict\_backchannel) | Enable strict hostname validation for backchannel | `bool` | `false` | no |
| <a name="input_http_enabled"></a> [http\_enabled](#input\_http\_enabled) | Enable HTTP (non-TLS) access | `bool` | `true` | no |
| <a name="input_ingress_additional_annotations"></a> [ingress\_additional\_annotations](#input\_ingress\_additional\_annotations) | Additional annotations for the ingress | `map(string)` | `{}` | no |
| <a name="input_ingress_certificate_arn"></a> [ingress\_certificate\_arn](#input\_ingress\_certificate\_arn) | ACM certificate ARN for HTTPS (optional, uses auto-discovery if not set) | `string` | `null` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | Ingress class name | `string` | `"alb"` | no |
| <a name="input_ingress_group_name"></a> [ingress\_group\_name](#input\_ingress\_group\_name) | ALB ingress group name for sharing ALB across services | `string` | `"external"` | no |
| <a name="input_ingress_healthcheck_healthy_threshold"></a> [ingress\_healthcheck\_healthy\_threshold](#input\_ingress\_healthcheck\_healthy\_threshold) | Number of consecutive successful health checks | `number` | `2` | no |
| <a name="input_ingress_healthcheck_interval"></a> [ingress\_healthcheck\_interval](#input\_ingress\_healthcheck\_interval) | Health check interval in seconds | `number` | `15` | no |
| <a name="input_ingress_healthcheck_path"></a> [ingress\_healthcheck\_path](#input\_ingress\_healthcheck\_path) | Health check path for ALB | `string` | `"/health"` | no |
| <a name="input_ingress_healthcheck_timeout"></a> [ingress\_healthcheck\_timeout](#input\_ingress\_healthcheck\_timeout) | Health check timeout in seconds | `number` | `5` | no |
| <a name="input_ingress_healthcheck_unhealthy_threshold"></a> [ingress\_healthcheck\_unhealthy\_threshold](#input\_ingress\_healthcheck\_unhealthy\_threshold) | Number of consecutive failed health checks | `number` | `3` | no |
| <a name="input_ingress_scheme"></a> [ingress\_scheme](#input\_ingress\_scheme) | ALB scheme (internet-facing or internal) | `string` | `"internet-facing"` | no |
| <a name="input_ingress_ssl_redirect"></a> [ingress\_ssl\_redirect](#input\_ingress\_ssl\_redirect) | Enable SSL redirect on ALB | `bool` | `true` | no |
| <a name="input_ingress_target_type"></a> [ingress\_target\_type](#input\_ingress\_target\_type) | ALB target type (ip or instance) | `string` | `"ip"` | no |
| <a name="input_install_operator"></a> [install\_operator](#input\_install\_operator) | Whether to install the Keycloak Operator (set false if already installed cluster-wide) | `bool` | `true` | no |
| <a name="input_keycloak_image"></a> [keycloak\_image](#input\_keycloak\_image) | Keycloak container image | `string` | `"quay.io/keycloak/keycloak:26.0.7"` | no |
| <a name="input_keycloak_image_pull_secrets"></a> [keycloak\_image\_pull\_secrets](#input\_keycloak\_image\_pull\_secrets) | Image pull secrets for Keycloak container | `list(string)` | `[]` | no |
| <a name="input_keycloak_instances"></a> [keycloak\_instances](#input\_keycloak\_instances) | Number of Keycloak replicas for high availability | `number` | `2` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Keycloak deployment | `string` | `"keycloak"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for Keycloak | `string` | `"keycloak"` | no |
| <a name="input_olm_catalog_source"></a> [olm\_catalog\_source](#input\_olm\_catalog\_source) | OLM catalog source name | `string` | `"operatorhubio-catalog"` | no |
| <a name="input_olm_catalog_source_namespace"></a> [olm\_catalog\_source\_namespace](#input\_olm\_catalog\_source\_namespace) | OLM catalog source namespace | `string` | `"olm"` | no |
| <a name="input_olm_channel"></a> [olm\_channel](#input\_olm\_channel) | OLM subscription channel (fast, stable) | `string` | `"fast"` | no |
| <a name="input_olm_install_plan_approval"></a> [olm\_install\_plan\_approval](#input\_olm\_install\_plan\_approval) | OLM install plan approval mode (Automatic or Manual) | `string` | `"Automatic"` | no |
| <a name="input_olm_starting_csv"></a> [olm\_starting\_csv](#input\_olm\_starting\_csv) | Specific CSV version to install (leave empty for latest) | `string` | `""` | no |
| <a name="input_operator_install_method"></a> [operator\_install\_method](#input\_operator\_install\_method) | Method to install the operator: 'olm' (recommended, requires OLM on cluster) or 'manifest' (direct CRD/deployment) | `string` | `"olm"` | no |
| <a name="input_operator_namespace"></a> [operator\_namespace](#input\_operator\_namespace) | Namespace for the Keycloak Operator | `string` | `"keycloak-operator"` | no |
| <a name="input_operator_version"></a> [operator\_version](#input\_operator\_version) | Keycloak Operator version (used for manifest installation) | `string` | `"26.0.7"` | no |
| <a name="input_proxy_headers"></a> [proxy\_headers](#input\_proxy\_headers) | Proxy headers mode (xforwarded or forwarded) | `string` | `"xforwarded"` | no |
| <a name="input_realm_imports"></a> [realm\_imports](#input\_realm\_imports) | Map of realm configurations to import on startup | `map(any)` | `{}` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Resource requests and limits for Keycloak pods | <pre>object({<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>    limits = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "limits": {<br/>    "cpu": "2",<br/>    "memory": "2Gi"<br/>  },<br/>  "requests": {<br/>    "cpu": "500m",<br/>    "memory": "1Gi"<br/>  }<br/>}</pre> | no |
| <a name="input_tls_secret_name"></a> [tls\_secret\_name](#input\_tls\_secret\_name) | Kubernetes TLS secret name for HTTPS | `string` | `null` | no |
| <a name="input_transaction_xa_enabled"></a> [transaction\_xa\_enabled](#input\_transaction\_xa\_enabled) | Enable XA transactions | `bool` | `false` | no |
| <a name="input_unsupported_pod_template"></a> [unsupported\_pod\_template](#input\_unsupported\_pod\_template) | Raw pod template spec for unsupported configurations | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_credentials_secret"></a> [admin\_credentials\_secret](#output\_admin\_credentials\_secret) | Kubernetes secret name containing initial admin credentials |
| <a name="output_ingress_name"></a> [ingress\_name](#output\_ingress\_name) | Name of the ingress resource (if created) |
| <a name="output_keycloak_admin_hostname"></a> [keycloak\_admin\_hostname](#output\_keycloak\_admin\_hostname) | Admin console hostname (if different from primary) |
| <a name="output_keycloak_hostname"></a> [keycloak\_hostname](#output\_keycloak\_hostname) | Primary hostname for Keycloak |
| <a name="output_keycloak_instances"></a> [keycloak\_instances](#output\_keycloak\_instances) | Number of Keycloak replicas |
| <a name="output_keycloak_name"></a> [keycloak\_name](#output\_keycloak\_name) | Name of the Keycloak custom resource |
| <a name="output_keycloak_namespace"></a> [keycloak\_namespace](#output\_keycloak\_namespace) | Namespace where Keycloak is deployed |
| <a name="output_keycloak_service_name"></a> [keycloak\_service\_name](#output\_keycloak\_service\_name) | Name of the Keycloak service |
| <a name="output_operator_install_method"></a> [operator\_install\_method](#output\_operator\_install\_method) | Method used to install the operator (olm or manifest) |
| <a name="output_operator_namespace"></a> [operator\_namespace](#output\_operator\_namespace) | Namespace where the Keycloak Operator is deployed |
| <a name="output_realm_imports"></a> [realm\_imports](#output\_realm\_imports) | Map of realm import resource names |
<!-- END_TF_DOCS -->

## Verification

After deployment:

```bash
# Check operator status (OLM)
kubectl get csv -n keycloak-operator

# Check Keycloak CR status
kubectl get keycloak -n keycloak

# Get initial admin password
kubectl get secret keycloak-initial-admin -n keycloak -o jsonpath='{.data.password}' | base64 -d

# Test health endpoint
curl https://keycloak.example.com/health
```

## Updating CRDs

For manifest installations, use the update script:

```bash
./scripts/update-crds.sh 26.0.7
```

## Migration from Helm Chart

If migrating from the Bitnami Helm chart:

1. Provision external PostgreSQL (RDS recommended)
2. Export existing realm configurations
3. Create Kubernetes secrets for DB credentials
4. Deploy this module with `install_operator = true`
5. Import realms using `realm_imports` or KeycloakRealmImport CRs
6. Update DNS to point to new ingress

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Terraform Module                          │
├─────────────────────────────────────────────────────────────┤
│  1. Operator Installation (via OLM or Manifest)             │
│     - OperatorGroup + Subscription (OLM)                    │
│     - CRDs + Deployment (Manifest)                          │
│                                                              │
│  2. Keycloak CR                                              │
│     - Database connection (external PostgreSQL)              │
│     - TLS/HTTP configuration                                 │
│     - Resource limits                                        │
│     - HA settings (2+ replicas)                              │
│                                                              │
│  3. AWS ALB Ingress                                          │
│     - kubernetes_ingress_v1 resource                         │
│     - ALB annotations for AWS Load Balancer Controller       │
│                                                              │
│  4. Realm Imports (Optional)                                 │
│     - KeycloakRealmImport CRs for initial configuration      │
└─────────────────────────────────────────────────────────────┘
```

## License

Apache 2.0
