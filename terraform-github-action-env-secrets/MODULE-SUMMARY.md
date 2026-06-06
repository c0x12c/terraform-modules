# terraform-github-action-env-secrets Module Summary

## Overview

A Terraform module for managing GitHub Actions **environment secrets**. This module is based on `terraform-github-action-secrets` but specifically targets environment-scoped secrets instead of repository-level secrets.

## Key Differences from terraform-github-action-secrets

| Feature | terraform-github-action-secrets | terraform-github-action-env-secrets |
|---------|--------------------------------|-------------------------------------|
| **Scope** | Repository-level | Environment-level |
| **Resource** | `github_actions_secret` | `github_actions_environment_secret` |
| **Variables** | `repository`, `secrets` | `repository`, `environment`, `secrets` |
| **Use Case** | Global secrets for all workflows | Environment-specific secrets (prod, staging, etc.) |
| **Protection** | No environment protection | Can use GitHub environment protection rules |
| **Access Control** | All workflows can access | Only workflows targeting that environment |

## Module Structure

```
terraform-github-action-env-secrets/
├── main.tf                          # Main resource definition
├── variables.tf                     # Input variables
├── outputs.tf                       # Output values
├── versions.tf                      # Provider version constraints
├── README.md                        # Comprehensive documentation
├── CHANGELOG.md                     # Version history
├── .gitignore                       # Git ignore rules
└── example/
    └── complete/
        ├── main.tf                  # Complete example
        ├── variables.tf             # Example variables
        ├── provider.tf              # Provider configuration
        └── README.md                # Example documentation
```

## Files Created

### Core Module Files

1. **main.tf**
   - Resource: `github_actions_environment_secret`
   - Uses `for_each` to create multiple secrets
   - Requires: repository, environment, secret_name, plaintext_value

2. **variables.tf**
   - `repository` (string): GitHub repository name
   - `environment` (string): Environment name (production, staging, etc.)
   - `secrets` (map(string), sensitive): Map of secret name to value

3. **outputs.tf**
   - `secret_names`: List of created secret names
   - `environment`: Environment where secrets were created
   - `repository`: Repository where secrets were created

4. **versions.tf**
   - Terraform >= 1.9.8
   - GitHub provider >= 6.4.0

### Documentation Files

5. **README.md**
   - Comprehensive usage guide
   - Multiple examples (basic, multi-env, dynamic)
   - GitHub Actions workflow integration
   - Security best practices
   - Troubleshooting guide
   - Comparison with repository secrets
   - Migration guide

6. **CHANGELOG.md**
   - Version 1.0.0 initial release notes

7. **.gitignore**
   - Standard Terraform ignore patterns
   - Protects sensitive tfvars files

### Example Files

8. **example/complete/main.tf**
   - Shows usage for 3 environments (production, staging, development)
   - Demonstrates multiple secrets per environment
   - Includes outputs

9. **example/complete/variables.tf**
   - GitHub token variable
   - GitHub owner variable

10. **example/complete/provider.tf**
    - Provider configuration
    - Version constraints

11. **example/complete/README.md**
    - Setup instructions
    - Prerequisites
    - Usage guide
    - Security notes

## Usage Patterns

### Basic Usage

```hcl
module "production_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  version = "~> 1.0.0"

  repository  = "my-app"
  environment = "production"

  secrets = {
    "DATABASE_URL" = "postgresql://prod-db:5432/myapp"
    "API_KEY"      = "prod-api-key-123"
  }
}
```

### Multiple Environments

```hcl
module "prod_secrets" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "my-app"
  environment = "production"
  secrets     = var.prod_secrets
}

module "staging_secrets" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "my-app"
  environment = "staging"
  secrets     = var.staging_secrets
}
```

### Dynamic Environments

```hcl
locals {
  environments = {
    production = { "API_KEY" = "prod-key" }
    staging    = { "API_KEY" = "staging-key" }
  }
}

module "env_secrets" {
  source   = "c0x12c/action-env-secrets/github"
  for_each = local.environments

  repository  = "my-app"
  environment = each.key
  secrets     = each.value
}
```

## GitHub Actions Integration

Once secrets are created, reference them in workflows:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Links to the environment

    steps:
      - name: Deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
        run: ./deploy.sh
```

## Key Features

✅ **Environment Scoping**: Secrets are isolated per environment
✅ **Batch Creation**: Create multiple secrets at once
✅ **Sensitive Handling**: Variables marked as sensitive
✅ **Output Tracking**: Know which secrets were created
✅ **Easy Migration**: Simple migration from repository secrets
✅ **Security Best Practices**: Documentation includes security guidance

## Prerequisites

1. **GitHub Repository**: Must exist before running module
2. **GitHub Environment**: Must be created in repository settings
3. **GitHub Token**: PAT with `repo` and `admin:repo_hook` permissions
4. **Terraform**: Version >= 1.9.8
5. **GitHub Provider**: Version >= 6.4.0

## Security Considerations

1. **Never commit secrets to version control**
2. **Use sensitive variables** for secret values
3. **Store secrets in Terraform Cloud/Enterprise**
4. **Implement environment protection rules in GitHub**
5. **Use least privilege access for GitHub tokens**

## Comparison Table

| Scenario | Use Repository Secrets | Use Environment Secrets |
|----------|----------------------|------------------------|
| Same value across all environments | ✅ | ❌ |
| Different values per environment | ❌ | ✅ |
| Need environment protection | ❌ | ✅ |
| Simple global configuration | ✅ | ❌ |
| Production vs staging separation | ❌ | ✅ |
| Require deployment approvals | ❌ | ✅ |

## Next Steps

1. **Test in Development**: Try the example in a test repository
2. **Create Environments**: Set up environments in GitHub
3. **Configure Secrets**: Define your secrets map
4. **Apply Module**: Run terraform apply
5. **Update Workflows**: Add `environment:` to your jobs
6. **Monitor**: Verify secrets work in Actions runs

## Related Modules

- [terraform-github-action-secrets](../terraform-github-action-secrets) - Repository-level secrets
- [terraform-github-action-variables](../terraform-github-action-variables) - Action variables (if created)

## Support

- GitHub Provider Docs: https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret
- GitHub Environments: https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment
- Module Repository: Report issues in the module repository
