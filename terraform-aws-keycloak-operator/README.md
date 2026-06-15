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

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| `hostname` | Keycloak hostname | `string` |
| `db_host` | PostgreSQL database host | `string` |
| `db_username_secret` | K8s secret reference for DB username | `object({name, key})` |
| `db_password_secret` | K8s secret reference for DB password | `object({name, key})` |

### Operator Configuration

| Name | Description | Default |
|------|-------------|---------|
| `install_operator` | Install Keycloak Operator | `true` |
| `operator_install_method` | Installation method: `olm` or `manifest` | `"olm"` |
| `operator_namespace` | Operator namespace | `"keycloak-operator"` |
| `olm_channel` | OLM subscription channel | `"fast"` |
| `olm_install_plan_approval` | OLM install plan approval | `"Automatic"` |

### Keycloak Configuration

| Name | Description | Default |
|------|-------------|---------|
| `name` | Keycloak deployment name | `"keycloak"` |
| `namespace` | Keycloak namespace | `"keycloak"` |
| `keycloak_instances` | Number of replicas | `2` |
| `keycloak_image` | Container image | `"quay.io/keycloak/keycloak:26.0.7"` |

### Ingress Configuration

| Name | Description | Default |
|------|-------------|---------|
| `create_ingress` | Create AWS ALB Ingress | `true` |
| `ingress_class_name` | Ingress class | `"alb"` |
| `ingress_group_name` | ALB group name | `"external"` |
| `ingress_scheme` | ALB scheme | `"internet-facing"` |

See [variables.tf](variables.tf) for complete list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| `keycloak_name` | Keycloak CR name |
| `keycloak_namespace` | Deployment namespace |
| `keycloak_hostname` | Primary hostname |
| `admin_credentials_secret` | Secret with initial admin credentials |
| `keycloak_service_name` | Service name |
| `operator_install_method` | Installation method used |

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
