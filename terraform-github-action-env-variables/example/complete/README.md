# Complete Example

This example demonstrates how to use the `terraform-github-action-env-variables` module to create environment-specific variables for multiple GitHub environments.

## Prerequisites

1. **GitHub Repository**: You need an existing GitHub repository
2. **GitHub Environments**: Create the following environments in your repository:
   - `production`
   - `staging`
   - `development`

   To create environments:
   - Go to your repository → Settings → Environments
   - Click "New environment"
   - Enter the environment name

3. **GitHub Token**: A personal access token with:
   - `repo` (Full control of private repositories)
   - Write access to Actions variables

## Setup

1. Set your GitHub token:

```bash
export TF_VAR_github_token="your-github-token"
export TF_VAR_github_owner="your-github-org-or-username"
```

Or create a `terraform.tfvars` file:

```hcl
github_token = "your-github-token"
github_owner = "your-github-org-or-username"
```

2. Initialize Terraform:

```bash
terraform init
```

3. Review the plan:

```bash
terraform plan
```

4. Apply the configuration:

```bash
terraform apply
```

## What This Example Creates

This example creates variables in three different environments:

### Production Environment
- `NODE_ENV=production`
- `LOG_LEVEL=error`
- `DEBUG_MODE=false`
- `API_ENDPOINT=https://api.example.com`
- `AWS_REGION=us-east-1`
- And more...

### Staging Environment
- Same variable names with staging-specific values
- More verbose logging (`LOG_LEVEL=warn`)
- Debug mode enabled

### Development Environment
- Same variable names with development-specific values
- Most verbose logging (`LOG_LEVEL=debug`)
- Extended timeouts for testing

## Using Variables in GitHub Actions

After running this example, use the variables in your workflows:

```yaml
name: Deploy Application

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # This references the production environment

    steps:
      - uses: actions/checkout@v4

      - name: Configure Application
        env:
          NODE_ENV: ${{ vars.NODE_ENV }}
          LOG_LEVEL: ${{ vars.LOG_LEVEL }}
          API_ENDPOINT: ${{ vars.API_ENDPOINT }}
          AWS_REGION: ${{ vars.AWS_REGION }}
        run: |
          echo "Deploying to $NODE_ENV environment"
          echo "API Endpoint: $API_ENDPOINT"
          echo "Log Level: $LOG_LEVEL"

      - name: Run Application
        run: |
          npm install
          npm run build
          npm run deploy
```

## Variables vs Secrets

⚠️ **Important**: Variables are NOT encrypted and are visible in logs.

For sensitive data, use environment secrets instead:

```hcl
# Configuration (this module - variables)
module "config" {
  source      = "c0x12c/action-env-variables/github"
  repository  = "my-app"
  environment = "production"
  variables = {
    "API_ENDPOINT" = "https://api.example.com"
  }
}

# Credentials (use env-secrets module)
module "credentials" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "my-app"
  environment = "production"
  secrets = {
    "API_KEY" = var.api_key
  }
}
```

## Clean Up

To remove all created variables:

```bash
terraform destroy
```

## Advanced Usage

### Dynamic Environments

Create variables for multiple environments dynamically:

```hcl
locals {
  environments = {
    production = {
      "LOG_LEVEL" = "error"
      "DEBUG"     = "false"
    }
    staging = {
      "LOG_LEVEL" = "warn"
      "DEBUG"     = "true"
    }
  }
}

module "env_variables" {
  source   = "../../"
  for_each = local.environments

  repository  = "my-application"
  environment = each.key
  variables   = each.value
}
```

### Feature Flags

Use variables for feature flags:

```hcl
module "feature_flags" {
  source      = "../../"
  repository  = "my-app"
  environment = "production"

  variables = {
    "FEATURE_NEW_UI"     = "enabled"
    "FEATURE_BETA_API"   = "disabled"
    "FEATURE_DARK_MODE"  = "enabled"
  }
}
```

### Multi-Region Configuration

```hcl
locals {
  regions = ["us-east-1", "eu-west-1", "ap-southeast-1"]
}

module "region_config" {
  source   = "../../"
  for_each = toset(local.regions)

  repository  = "my-app"
  environment = "prod-${each.value}"

  variables = {
    "AWS_REGION"    = each.value
    "S3_BUCKET"     = "my-app-${each.value}"
    "CDN_ENDPOINT"  = "cdn-${each.value}.example.com"
  }
}
```

## Troubleshooting

### Variables not showing in workflow

Make sure your workflow job specifies the environment:

```yaml
jobs:
  deploy:
    environment: production  # Must match the environment name
```

### "Environment not found" error

Create the environment in GitHub first:
1. Repository → Settings → Environments
2. Click "New environment"
3. Enter the environment name

### Variables visible when they shouldn't be

Variables are meant to be visible - they're not encrypted. For sensitive data, use the `terraform-github-action-env-secrets` module instead.

## Security Notes

- Variables are **NOT encrypted** and will appear in logs
- Never put passwords, API keys, or tokens in variables
- Use environment **secrets** for sensitive data
- Add `terraform.tfvars` to `.gitignore`

## Next Steps

1. Combine with environment secrets for complete configuration
2. Add environment protection rules in GitHub
3. Implement approval workflows for production
4. Set up branch protection rules
