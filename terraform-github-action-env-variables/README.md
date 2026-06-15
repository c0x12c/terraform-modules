# GitHub Actions Environment Variables Terraform Module

This module creates GitHub Actions environment variables for specific deployment environments within a GitHub repository. Environment variables are non-sensitive configuration values that are scoped to particular environments (e.g., production, staging, development).

## Features

- 🌍 **Environment-Scoped Variables**: Variables isolated to specific environments
- 📝 **Non-Sensitive Configuration**: For public configuration values (use environment secrets for sensitive data)
- 🎯 **Simple Interface**: Easy map-based variable configuration
- 🔄 **Batch Creation**: Create multiple variables at once
- 📊 **Output Tracking**: Track created variable names and environment details

## Variables vs Secrets

| Feature | Variables | Secrets |
|---------|-----------|---------|
| **Visibility** | Can be seen in logs | Masked in logs |
| **Use Case** | Configuration, URLs, flags | API keys, passwords, tokens |
| **Access** | Readable in workflow | Encrypted, not readable |
| **Example** | `NODE_ENV=production` | `API_KEY=secret123` |

**Use this module** for non-sensitive environment configuration.

**Use terraform-github-action-env-secrets** for sensitive values.

## Usage

### Basic Example

```hcl
module "production_variables" {
  source  = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  version = "1.0.0"

  repository  = "my-application"
  environment = "production"

  variables = {
    "NODE_ENV"          = "production"
    "LOG_LEVEL"         = "info"
    "API_ENDPOINT"      = "https://api.example.com"
    "REGION"            = "us-east-1"
    "CACHE_TTL"         = "3600"
  }
}
```

### Multiple Environments

```hcl
# Production environment variables
module "production_variables" {
  source  = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  version = "1.0.0"

  repository  = "my-application"
  environment = "production"

  variables = {
    "NODE_ENV"      = "production"
    "LOG_LEVEL"     = "error"
    "API_ENDPOINT"  = "https://api.example.com"
    "DEBUG_MODE"    = "false"
  }
}

# Staging environment variables
module "staging_variables" {
  source  = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  version = "1.0.0"

  repository  = "my-application"
  environment = "staging"

  variables = {
    "NODE_ENV"      = "staging"
    "LOG_LEVEL"     = "debug"
    "API_ENDPOINT"  = "https://staging-api.example.com"
    "DEBUG_MODE"    = "true"
  }
}

# Development environment variables
module "development_variables" {
  source  = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  version = "1.0.0"

  repository  = "my-application"
  environment = "development"

  variables = {
    "NODE_ENV"      = "development"
    "LOG_LEVEL"     = "debug"
    "API_ENDPOINT"  = "https://dev-api.example.com"
    "DEBUG_MODE"    = "true"
  }
}
```

### Dynamic Environment Variables

```hcl
locals {
  environments = ["production", "staging", "development"]

  # Define variables per environment
  environment_variables = {
    production = {
      "NODE_ENV"     = "production"
      "LOG_LEVEL"    = "error"
      "API_ENDPOINT" = "https://api.example.com"
    }
    staging = {
      "NODE_ENV"     = "staging"
      "LOG_LEVEL"    = "warn"
      "API_ENDPOINT" = "https://staging-api.example.com"
    }
    development = {
      "NODE_ENV"     = "development"
      "LOG_LEVEL"    = "debug"
      "API_ENDPOINT" = "https://dev-api.example.com"
    }
  }
}

module "environment_variables" {
  source   = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  version  = "1.0.0"
  for_each = local.environment_variables

  repository  = "my-application"
  environment = each.key
  variables   = each.value
}
```

### Combined with Environment Secrets

```hcl
# Non-sensitive configuration variables
module "production_variables" {
  source      = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  repository  = "my-app"
  environment = "production"

  variables = {
    "API_ENDPOINT"  = "https://api.example.com"
    "LOG_LEVEL"     = "info"
    "REGION"        = "us-east-1"
  }
}

# Sensitive secrets
module "production_secrets" {
  source      = "terraform.c0x12c.com/c0x12c/action-env-secrets/github"
  repository  = "my-app"
  environment = "production"

  secrets = {
    "API_KEY"       = var.prod_api_key
    "DATABASE_URL"  = var.prod_database_url
  }
}
```

## GitHub Actions Workflow Example

```yaml
name: Deploy Application

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

      - name: Configure Application
        env:
          # Environment variables are automatically available
          NODE_ENV: ${{ vars.NODE_ENV }}
          LOG_LEVEL: ${{ vars.LOG_LEVEL }}
          API_ENDPOINT: ${{ vars.API_ENDPOINT }}
          # Secrets use a different syntax
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          echo "Environment: $NODE_ENV"
          echo "API Endpoint: $API_ENDPOINT"
          ./deploy.sh

      - name: Show variable (for debugging)
        run: |
          echo "Log level is set to: ${{ vars.LOG_LEVEL }}"
```

## Environment Setup

Before using this module:

1. **Create the GitHub Environment**:
   - Go to repository → Settings → Environments
   - Click "New environment"
   - Enter environment name (must match `var.environment`)

2. **Configure GitHub Provider**:

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

## Use Cases

### Configuration Management
```hcl
module "app_config" {
  source      = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  repository  = "my-app"
  environment = "production"

  variables = {
    "APP_NAME"          = "My Application"
    "APP_VERSION"       = "2.1.0"
    "FEATURE_FLAG_X"    = "enabled"
    "MAX_RETRIES"       = "3"
    "TIMEOUT_SECONDS"   = "30"
  }
}
```

### Multi-Region Deployment
```hcl
locals {
  regions = {
    us-east = {
      "REGION"         = "us-east-1"
      "CDN_ENDPOINT"   = "cdn-east.example.com"
      "S3_BUCKET"      = "my-app-east"
    }
    eu-west = {
      "REGION"         = "eu-west-1"
      "CDN_ENDPOINT"   = "cdn-eu.example.com"
      "S3_BUCKET"      = "my-app-eu"
    }
  }
}

module "region_variables" {
  source   = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  for_each = local.regions

  repository  = "my-app"
  environment = each.key
  variables   = each.value
}
```

### Feature Flags
```hcl
module "feature_flags" {
  source      = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  repository  = "my-app"
  environment = "production"

  variables = {
    "FEATURE_NEW_UI"        = "enabled"
    "FEATURE_BETA_API"      = "disabled"
    "FEATURE_DARK_MODE"     = "enabled"
    "FEATURE_A_B_TEST"      = "variant_a"
  }
}
```

## Important Notes

### Variables vs Secrets Comparison

| Aspect | Environment Variables (This Module) | Environment Secrets |
|--------|-------------------------------------|---------------------|
| **Module** | terraform-github-action-env-variables | terraform-github-action-env-secrets |
| **Resource** | `github_actions_environment_variable` | `github_actions_environment_secret` |
| **Visibility** | ✅ Visible in logs | ❌ Masked in logs |
| **Encryption** | ❌ Not encrypted | ✅ Encrypted at rest |
| **Use for** | API URLs, regions, flags | API keys, passwords, tokens |
| **Example** | `API_URL=https://api.com` | `API_KEY=secret123` |

### When to Use Variables

✅ **Use Environment Variables for:**
- API endpoints and URLs
- Configuration flags
- Environment names
- Log levels
- Timeouts and limits
- Feature flags
- Public configuration

❌ **Don't Use Variables for:**
- API keys or tokens
- Passwords
- Database credentials
- Private keys
- Any sensitive data

### Security Best Practices

1. **Never store sensitive data in variables**
   ```hcl
   # ❌ BAD - Don't put secrets in variables
   variables = {
     "API_KEY" = "secret-key-123"  # Use secrets instead!
   }

   # ✅ GOOD - Use variables for configuration
   variables = {
     "API_ENDPOINT" = "https://api.example.com"
   }
   ```

2. **Use secrets for sensitive values**
   ```hcl
   # Configuration (variables)
   module "config" {
     source      = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
     repository  = "app"
     environment = "prod"
     variables   = { "API_URL" = "https://api.com" }
   }

   # Credentials (secrets)
   module "credentials" {
     source      = "terraform.c0x12c.com/c0x12c/action-env-secrets/github"
     repository  = "app"
     environment = "prod"
     secrets     = { "API_KEY" = var.api_key }
   }
   ```

3. **Variables are visible** - Anyone with repository access can see them
4. **Use environment protection rules** for production environments

### Permissions Required

The GitHub token must have:
- **Repository**: `admin` or `write` access
- **Variables**: Write access to Actions variables

## Comparison with Repository Variables

### terraform-github-action-variables (Repository-Level)

```hcl
# Repository-level variables (available to all workflows)
module "repo_variables" {
  source     = "terraform.c0x12c.com/c0x12c/action-variables/github"
  repository = "my-app"
  variables = {
    "GLOBAL_CONFIG" = "value"
  }
}
```

### terraform-github-action-env-variables (Environment-Level) - This Module

```hcl
# Environment-level variables (only available to specific environment)
module "env_variables" {
  source      = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  repository  = "my-app"
  environment = "production"  # Additional scoping
  variables = {
    "ENV_SPECIFIC_CONFIG" = "value"
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
| [github_actions_environment_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the GitHub environment (e.g., 'production', 'staging', 'development') | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Name of the GitHub repository | `string` | n/a | yes |
| <a name="input_variables"></a> [variables](#input\_variables) | Map of variables to be set in the repository environment. Key is the variable name, value is the variable value. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_environment"></a> [environment](#output\_environment) | Name of the GitHub environment where variables were created |
| <a name="output_repository"></a> [repository](#output\_repository) | Name of the GitHub repository where variables were created |
| <a name="output_variable_names"></a> [variable\_names](#output\_variable\_names) | List of variable names created in the environment |
<!-- END_TF_DOCS -->

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

### Variables not appearing in workflow

**Cause**: Workflow doesn't reference the environment.

**Solution**: Add `environment: <name>` to your job:
```yaml
jobs:
  deploy:
    environment: production  # Must match module's environment variable
```

### Variables showing in logs when they shouldn't

**Cause**: Variables are not masked - they're meant to be visible.

**Solution**: If the value is sensitive, use environment **secrets** instead:
```hcl
# Use terraform-github-action-env-secrets module
module "secrets" {
  source      = "terraform.c0x12c.com/c0x12c/action-env-secrets/github"
  repository  = "app"
  environment = "prod"
  secrets     = { "SENSITIVE_VALUE" = var.secret }
}
```

## Migration Guide

### From Repository Variables to Environment Variables

```hcl
# Before: Repository-level variable
module "old_variables" {
  source     = "terraform.c0x12c.com/c0x12c/action-variables/github"
  repository = "my-app"
  variables = {
    "CONFIG" = "value"
  }
}

# After: Environment-level variable
module "new_variables" {
  source      = "terraform.c0x12c.com/c0x12c/action-env-variables/github"
  repository  = "my-app"
  environment = "production"
  variables = {
    "CONFIG" = "value"
  }
}
```

Update workflow:
```yaml
jobs:
  deploy:
    environment: production  # Add this line
    steps:
      - name: Use variable
        env:
          CONFIG: ${{ vars.CONFIG }}
        run: echo "Using config"
```

## Related Modules

- [terraform-github-action-variables](../terraform-github-action-variables) - Repository-level variables
- [terraform-github-action-env-secrets](../terraform-github-action-env-secrets) - Environment-level secrets
- [terraform-github-action-secrets](../terraform-github-action-secrets) - Repository-level secrets

## Contributing

Contributions welcome! Please:
1. Test changes in a non-production repository
2. Update documentation
3. Follow existing code style

## License

This module is provided as-is under the MIT License.

## Support

- Open issues in the repository
- Check [GitHub's variables documentation](https://docs.github.com/en/actions/learn-github-actions/variables)
- Review [GitHub's environment documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
