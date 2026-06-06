# GitHub Actions Terraform Modules Comparison

Complete comparison of all GitHub Actions Terraform modules for managing secrets and variables.

## Module Overview

| Module | Scope | Data Type | Visibility | Use Case |
|--------|-------|-----------|------------|----------|
| [terraform-github-action-secrets](../terraform-github-action-secrets) | Repository | Secrets | Encrypted | Global sensitive data |
| [terraform-github-action-variables](../terraform-github-action-variables) | Repository | Variables | Visible | Global configuration |
| [terraform-github-action-env-secrets](../terraform-github-action-env-secrets) | Environment | Secrets | Encrypted | Environment-specific sensitive data |
| [terraform-github-action-env-variables](../terraform-github-action-env-variables) | Environment | Variables | Visible | Environment-specific configuration |

## Detailed Comparison

### 1. Repository-Level Secrets

**Module**: `terraform-github-action-secrets`

```hcl
module "repo_secrets" {
  source  = "c0x12c/action-secrets/github"
  repository = "my-app"
  secrets = {
    "GLOBAL_API_KEY" = "secret"
  }
}
```

**Characteristics**:
- ✅ Available to all workflows
- ✅ Encrypted and masked in logs
- ✅ Good for: Shared credentials, global tokens
- ❌ No environment isolation
- ❌ No protection rules

**GitHub Actions Usage**:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Use secret
        env:
          API_KEY: ${{ secrets.GLOBAL_API_KEY }}
        run: echo "Building"
```

---

### 2. Repository-Level Variables

**Module**: `terraform-github-action-variables`

```hcl
module "repo_variables" {
  source  = "c0x12c/action-variables/github"
  repository = "my-app"
  variables = {
    "APP_NAME" = "My Application"
  }
}
```

**Characteristics**:
- ✅ Available to all workflows
- ✅ Visible in logs
- ✅ Good for: App names, versions, global config
- ❌ Not encrypted
- ❌ No environment isolation

**GitHub Actions Usage**:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Use variable
        run: echo "App: ${{ vars.APP_NAME }}"
```

---

### 3. Environment-Level Secrets

**Module**: `terraform-github-action-env-secrets` ⭐

```hcl
module "prod_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  repository  = "my-app"
  environment = "production"
  secrets = {
    "DATABASE_PASSWORD" = "prod-secret"
  }
}
```

**Characteristics**:
- ✅ Environment-specific
- ✅ Encrypted and masked
- ✅ Supports environment protection rules
- ✅ Good for: Prod credentials, environment-specific tokens
- ✅ Can require approvals

**GitHub Actions Usage**:
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Required!
    steps:
      - name: Deploy
        env:
          DB_PASSWORD: ${{ secrets.DATABASE_PASSWORD }}
        run: ./deploy.sh
```

---

### 4. Environment-Level Variables

**Module**: `terraform-github-action-env-variables` ⭐ (This Module)

```hcl
module "prod_variables" {
  source  = "c0x12c/action-env-variables/github"
  repository  = "my-app"
  environment = "production"
  variables = {
    "API_ENDPOINT" = "https://api.example.com"
  }
}
```

**Characteristics**:
- ✅ Environment-specific
- ✅ Visible in logs
- ✅ Supports environment protection rules
- ✅ Good for: API URLs, feature flags, env config
- ❌ Not encrypted

**GitHub Actions Usage**:
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Required!
    steps:
      - name: Deploy
        env:
          API_URL: ${{ vars.API_ENDPOINT }}
        run: ./deploy.sh
```

---

## Decision Matrix

### When to Use Which Module?

```
Is the data sensitive?
├── YES (passwords, API keys, tokens)
│   ├── Needs environment isolation?
│   │   ├── YES → terraform-github-action-env-secrets ⭐
│   │   └── NO  → terraform-github-action-secrets
│   └── NO (configuration, URLs, flags)
│       ├── Needs environment isolation?
│       │   ├── YES → terraform-github-action-env-variables ⭐
│       │   └── NO  → terraform-github-action-variables
```

### Common Scenarios

#### Scenario 1: Multi-Environment Application

```hcl
# Environment-specific configuration (visible)
module "prod_config" {
  source      = "c0x12c/action-env-variables/github"
  repository  = "app"
  environment = "production"
  variables   = {
    "API_URL" = "https://api.example.com"
    "LOG_LEVEL" = "error"
  }
}

# Environment-specific credentials (encrypted)
module "prod_creds" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "app"
  environment = "production"
  secrets     = {
    "API_KEY" = var.prod_api_key
    "DB_PASSWORD" = var.prod_db_password
  }
}
```

#### Scenario 2: Shared Global Configuration

```hcl
# Global non-sensitive config
module "global_config" {
  source     = "c0x12c/action-variables/github"
  repository = "app"
  variables  = {
    "APP_NAME" = "My App"
    "VERSION" = "2.0.0"
  }
}

# Global shared credentials
module "global_secrets" {
  source     = "c0x12c/action-secrets/github"
  repository = "app"
  secrets    = {
    "NPM_TOKEN" = var.npm_token
  }
}
```

#### Scenario 3: Feature Flags by Environment

```hcl
# Production - stable features only
module "prod_flags" {
  source      = "c0x12c/action-env-variables/github"
  repository  = "app"
  environment = "production"
  variables   = {
    "FEATURE_NEW_UI" = "disabled"
    "FEATURE_BETA_API" = "disabled"
  }
}

# Staging - beta features enabled
module "staging_flags" {
  source      = "c0x12c/action-env-variables/github"
  repository  = "app"
  environment = "staging"
  variables   = {
    "FEATURE_NEW_UI" = "enabled"
    "FEATURE_BETA_API" = "enabled"
  }
}
```

---

## Syntax Comparison

### Accessing in Workflows

```yaml
jobs:
  example:
    runs-on: ubuntu-latest
    environment: production  # Only needed for env-level secrets/variables

    steps:
      # Repository-level secret
      - name: Use repo secret
        env:
          TOKEN: ${{ secrets.REPO_SECRET }}
        run: echo "Using secret"

      # Repository-level variable
      - name: Use repo variable
        run: echo "App: ${{ vars.REPO_VARIABLE }}"

      # Environment-level secret (requires environment: above)
      - name: Use env secret
        env:
          PASSWORD: ${{ secrets.ENV_SECRET }}
        run: echo "Using secret"

      # Environment-level variable (requires environment: above)
      - name: Use env variable
        run: echo "API: ${{ vars.ENV_VARIABLE }}"
```

---

## Feature Matrix

| Feature | Repo Secrets | Repo Variables | Env Secrets | Env Variables |
|---------|--------------|----------------|-------------|---------------|
| **Encrypted** | ✅ | ❌ | ✅ | ❌ |
| **Masked in logs** | ✅ | ❌ | ✅ | ❌ |
| **Environment scoped** | ❌ | ❌ | ✅ | ✅ |
| **Protection rules** | ❌ | ❌ | ✅ | ✅ |
| **Requires approvals** | ❌ | ❌ | ✅ | ✅ |
| **Visible in UI** | ❌ | ✅ | ❌ | ✅ |
| **Good for passwords** | ✅ | ❌ | ✅ | ❌ |
| **Good for URLs** | ❌ | ✅ | ❌ | ✅ |

---

## Best Practices

### ✅ Recommended Patterns

```hcl
# Pattern 1: Environment-specific deployment
module "prod_config" {
  source      = "c0x12c/action-env-variables/github"
  environment = "production"
  variables   = { "API_URL" = "https://api.prod.com" }
}

module "prod_secrets" {
  source      = "c0x12c/action-env-secrets/github"
  environment = "production"
  secrets     = { "API_KEY" = var.prod_key }
}

# Pattern 2: Global configuration with env-specific overrides
module "global_config" {
  source    = "c0x12c/action-variables/github"
  variables = { "APP_NAME" = "MyApp" }
}

module "env_config" {
  source      = "c0x12c/action-env-variables/github"
  environment = "production"
  variables   = { "REGION" = "us-east-1" }
}
```

### ❌ Anti-Patterns

```hcl
# ❌ BAD: Putting secrets in variables
module "bad_variables" {
  source    = "c0x12c/action-env-variables/github"
  variables = {
    "PASSWORD" = "secret123"  # Will be visible in logs!
  }
}

# ✅ GOOD: Use secrets for sensitive data
module "good_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  secrets = {
    "PASSWORD" = var.password
  }
}

# ❌ BAD: Using repo-level for environment-specific data
module "bad_repo_secret" {
  source  = "c0x12c/action-secrets/github"
  secrets = {
    "PROD_DB_PASSWORD" = var.prod_password
    "STAGING_DB_PASSWORD" = var.staging_password
  }
}

# ✅ GOOD: Use environment-level for isolation
module "good_env_secret" {
  source      = "c0x12c/action-env-secrets/github"
  environment = "production"
  secrets     = { "DB_PASSWORD" = var.prod_password }
}
```

---

## Migration Paths

### From Repository to Environment Scope

```hcl
# Before: Repository-level
module "old" {
  source     = "c0x12c/action-secrets/github"
  repository = "app"
  secrets    = { "API_KEY" = var.api_key }
}

# After: Environment-level
module "new" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "app"
  environment = "production"
  secrets     = { "API_KEY" = var.api_key }
}
```

Update workflow:
```yaml
# Add this line
environment: production
```

---

## Summary

### Quick Selection Guide

**Use Environment-Level (Preferred for most cases):**
- ✅ Different values per environment (prod, staging, dev)
- ✅ Need deployment protection
- ✅ Want approval workflows
- ✅ Isolate production credentials

**Use Repository-Level:**
- ✅ Same value across all environments
- ✅ Simple setup without environments
- ✅ Global configuration

### Module Selection Cheat Sheet

```
Sensitive + Multi-Environment    → terraform-github-action-env-secrets ⭐
Sensitive + Single Environment   → terraform-github-action-secrets
Config + Multi-Environment       → terraform-github-action-env-variables ⭐
Config + Single Environment      → terraform-github-action-variables
```

---

## Related Resources

- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [GitHub Variables Documentation](https://docs.github.com/en/actions/learn-github-actions/variables)
