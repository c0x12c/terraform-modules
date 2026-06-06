# # terraform-github-action-env-secrets

This module creates GitHub Actions environment secrets for a specific environment within a GitHub repository. Environment secrets are scoped to a particular deployment environment (e.g., production, staging, development) and provide better security isolation compared to repository-level secrets.

## Features

- 🔒 **Environment-Scoped Secrets**: Secrets are isolated to specific environments
- 🎯 **Simple Interface**: Easy-to-use map-based secret configuration
- 🔄 **Batch Creation**: Create multiple secrets at once
- 📊 **Output Tracking**: Track created secret names and environment details

## Use Cases

- **Multi-Environment Deployments**: Different credentials for staging vs production
- **Security Isolation**: Limit secret access to specific deployment environments
- **Compliance**: Meet security requirements for environment segregation
- **GitOps Workflows**: Manage environment secrets as code

## Usage

### Basic Example

```hcl
module "production_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  version = "~> 1.0.0"

  repository  = "my-application"
  environment = "production"

  secrets = {
    "AWS_ACCESS_KEY_ID"     = "AKIAIOSFODNN7EXAMPLE"
    "AWS_SECRET_ACCESS_KEY" = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    "DATABASE_URL"          = "postgresql://prod-db.example.com:5432/myapp"
    "API_KEY"               = "prod-api-key-12345"
  }
}
```

### Multiple Environments

```hcl
# Production environment secrets
module "production_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  version = "~> 1.0.0"

  repository  = "my-application"
  environment = "production"

  secrets = {
    "DATABASE_URL" = var.prod_database_url
    "API_KEY"      = var.prod_api_key
  }
}

# Staging environment secrets
module "staging_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  version = "~> 1.0.0"

  repository  = "my-application"
  environment = "staging"

  secrets = {
    "DATABASE_URL" = var.staging_database_url
    "API_KEY"      = var.staging_api_key
  }
}

# Development environment secrets
module "development_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  version = "~> 1.0.0"

  repository  = "my-application"
  environment = "development"

  secrets = {
    "DATABASE_URL" = var.dev_database_url
    "API_KEY"      = var.dev_api_key
  }
}
```

### Using with Sensitive Variables

```hcl
variable "prod_secrets" {
  description = "Production environment secrets"
  type        = map(string)
  sensitive   = true
}

module "production_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  version = "~> 1.0.0"

  repository  = "my-application"
  environment = "production"
  secrets     = var.prod_secrets
}
```

### Dynamic Secret Management

```hcl
locals {
  environments = ["production", "staging", "development"]

  # Define secrets per environment
  environment_secrets = {
    production = {
      "DATABASE_URL" = "postgresql://prod-db.example.com:5432/myapp"
      "API_KEY"      = "prod-key"
    }
    staging = {
      "DATABASE_URL" = "postgresql://staging-db.example.com:5432/myapp"
      "API_KEY"      = "staging-key"
    }
    development = {
      "DATABASE_URL" = "postgresql://dev-db.example.com:5432/myapp"
      "API_KEY"      = "dev-key"
    }
  }
}

module "environment_secrets" {
  source   = "c0x12c/action-env-secrets/github"
  version  = "~> 1.0.0"
  for_each = local.environment_secrets

  repository  = "my-application"
  environment = each.key
  secrets     = each.value
}
```

## GitHub Actions Workflow Example

Once secrets are created, use them in your GitHub Actions workflow:

```yaml
name: Deploy to Production

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # This references the environment

    steps:
      - uses: actions/checkout@v4

      - name: Deploy Application
        env:
          # Environment secrets are automatically available
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          ./deploy.sh
```

## Environment Setup

Before using this module, ensure you have:

1. **Created the GitHub Environment**:
   - Go to your repository → Settings → Environments
   - Create the environment (e.g., "production")
   - Configure protection rules if needed

2. **GitHub Provider Configuration**:

```hcl
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.4.0"
    }
  }
}

provider "github" {
  token = var.github_token  # or use GITHUB_TOKEN environment variable
  owner = var.github_owner
}
```

## Important Notes

### Environment vs Repository Secrets

| Feature | Environment Secrets | Repository Secrets |
|---------|--------------------|--------------------|
| Scope | Specific environment | Entire repository |
| Protection Rules | Can be configured | No protection rules |
| Access Control | Environment-based | Repository-wide |
| Use Case | Multi-environment deployments | Global configurations |

**Use this module** when you need environment-specific secrets.

**Use terraform-github-action-secrets** for repository-level secrets.

### Security Best Practices

1. **Never commit secrets to version control**
   ```hcl
   # ❌ BAD - Don't hardcode secrets
   secrets = {
     "API_KEY" = "hardcoded-secret-123"
   }

   # ✅ GOOD - Use variables
   secrets = var.production_secrets
   ```

2. **Use sensitive variables**
   ```hcl
   variable "production_secrets" {
     type      = map(string)
     sensitive = true  # Mark as sensitive
   }
   ```

3. **Leverage Terraform Cloud/Enterprise for secret management**
   - Store sensitive variables in Terraform Cloud
   - Use workspace-specific variables for different environments

4. **Implement least privilege access**
   - Use environment protection rules in GitHub
   - Require approvals for production deployments

### Permissions Required

The GitHub token must have the following permissions:
- **Repository**: `admin` or `write` access
- **Secrets**: Write access to Actions secrets

## Comparison with Similar Modules

### terraform-github-action-secrets (Repository-Level)

```hcl
# Repository-level secrets (available to all workflows)
module "repo_secrets" {
  source     = "c0x12c/action-secrets/github"
  repository = "my-app"
  secrets = {
    "GLOBAL_SECRET" = "value"
  }
}
```

### terraform-github-action-env-secrets (Environment-Level) - This Module

```hcl
# Environment-level secrets (only available to specific environment)
module "env_secrets" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "my-app"
  environment = "production"  # Additional scoping
  secrets = {
    "ENV_SPECIFIC_SECRET" = "value"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 6.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_environment_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the GitHub environment (e.g., 'production', 'staging', 'development') | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Name of the GitHub repository | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secrets to be set in the repository environment. Key is the secret name, value is the secret value. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_environment"></a> [environment](#output\_environment) | Name of the GitHub environment where secrets were created |
| <a name="output_repository"></a> [repository](#output\_repository) | Name of the GitHub repository where secrets were created |
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | List of secret names created in the environment |
<!-- END_TF_DOCS -->

## Migration from Repository Secrets

If you're migrating from repository-level secrets to environment secrets:

```hcl
# Before: Repository-level secret
module "old_secrets" {
  source     = "c0x12c/action-secrets/github"
  repository = "my-app"
  secrets = {
    "DATABASE_URL" = var.database_url
  }
}

# After: Environment-level secret
module "new_secrets" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "my-app"
  environment = "production"
  secrets = {
    "DATABASE_URL" = var.database_url
  }
}
```

Update your workflow to reference the environment:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Add this line
    steps:
      - name: Use secret
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: echo "Using database"
```

## Troubleshooting

### Error: "Environment not found"

**Cause**: The environment doesn't exist in the repository.

**Solution**: Create the environment in GitHub:
1. Go to repository Settings → Environments
2. Click "New environment"
3. Enter the environment name (must match `var.environment`)

### Error: "Resource not accessible by integration"

**Cause**: GitHub token lacks necessary permissions.

**Solution**: Ensure your token has `admin` or `write` access to the repository.

### Secrets not appearing in workflow

**Cause**: Workflow doesn't reference the environment.

**Solution**: Add `environment: <name>` to your job:
```yaml
jobs:
  deploy:
    environment: production  # Must match module's environment variable
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Test changes in a non-production repository
2. Update documentation for any new features
3. Follow existing code style and conventions

## License

This module is provided as-is under the MIT License.

## Related Modules

- [terraform-github-action-secrets](../terraform-github-action-secrets) - Repository-level secrets
- [terraform-github-action-variables](../terraform-github-action-variables) - Action variables (if available)

## Support

For issues and questions:
- Open an issue in the repository
- Check existing issues for similar problems
- Review GitHub's [environment secrets documentation](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-an-environment)
