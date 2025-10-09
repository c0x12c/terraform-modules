# Quick Start Guide

Get started with `terraform-github-action-env-variables` in 5 minutes.

## What Are Environment Variables?

Environment variables are **non-sensitive** configuration values scoped to GitHub environments:
- ✅ API endpoints, URLs
- ✅ Feature flags, configuration
- ✅ Log levels, timeouts
- ❌ **NOT for passwords or API keys** (use environment secrets instead)

## Prerequisites Checklist

- [ ] GitHub repository exists
- [ ] GitHub environment created (Settings → Environments → New environment)
- [ ] GitHub PAT token with `repo` permissions
- [ ] Terraform >= 1.9.8 installed

## Step 1: Create Environment in GitHub

1. Go to your repository on GitHub
2. **Settings** → **Environments**
3. Click **"New environment"**
4. Enter name (e.g., `production`)
5. Click **"Configure environment"**

## Step 2: Configure Provider

Create `main.tf`:

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
  token = var.github_token
  owner = var.github_owner
}
```

## Step 3: Use the Module

Add to `main.tf`:

```hcl
module "production_variables" {
  source  = "c0x12c/action-env-variables/github"
  version = "~> 1.0.0"

  repository  = "my-application"
  environment = "production"

  variables = {
    "NODE_ENV"      = "production"
    "LOG_LEVEL"     = "error"
    "API_ENDPOINT"  = "https://api.example.com"
  }
}
```

## Step 4: Define Variables

Create `variables.tf`:

```hcl
variable "github_token" {
  type      = string
  sensitive = true
}

variable "github_owner" {
  type = string
}
```

## Step 5: Set Token

**Option A: Environment Variable**
```bash
export TF_VAR_github_token="your-token"
export TF_VAR_github_owner="your-org"
```

**Option B: terraform.tfvars** (Don't commit!)
```hcl
github_token = "your-token"
github_owner = "your-org"
```

## Step 6: Apply

```bash
terraform init
terraform plan
terraform apply
```

## Step 7: Use in GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Link to environment

    steps:
      - uses: actions/checkout@v4

      - name: Show configuration
        run: |
          echo "Environment: ${{ vars.NODE_ENV }}"
          echo "API: ${{ vars.API_ENDPOINT }}"
          echo "Log Level: ${{ vars.LOG_LEVEL }}"
```

## Variables vs Secrets

| Use Variables For | Use Secrets For |
|-------------------|-----------------|
| ✅ API URLs | ❌ API Keys |
| ✅ Environment names | ❌ Passwords |
| ✅ Feature flags | ❌ Tokens |
| ✅ Log levels | ❌ Credentials |

**Variables are visible in logs** - Never put sensitive data in variables!

## Common Issues

### "Environment not found"
**Fix**: Create environment in GitHub Settings → Environments

### "Resource not accessible"
**Fix**: Token needs `repo` permission

### Variables not in workflow
**Fix**: Add `environment: production` to job

## Next Steps

- Add more environments (staging, development)
- Combine with environment secrets for sensitive data
- Set up environment protection rules
- Review full documentation in README.md

## Quick Reference

```hcl
# Minimal
module "vars" {
  source      = "c0x12c/action-env-variables/github"
  repository  = "repo-name"
  environment = "production"
  variables   = { "KEY" = "value" }
}

# Multiple environments
module "prod" {
  source      = "c0x12c/action-env-variables/github"
  repository  = "repo"
  environment = "production"
  variables   = var.prod_vars
}

module "staging" {
  source      = "c0x12c/action-env-variables/github"
  repository  = "repo"
  environment = "staging"
  variables   = var.staging_vars
}
```

## Security Reminder

```bash
# Add to .gitignore
echo "*.tfvars" >> .gitignore
```

⚠️ **Never put secrets in variables!** Use `terraform-github-action-env-secrets` for sensitive data.

---

**You're ready! 🎉** Your environment variables are now managed as code.
