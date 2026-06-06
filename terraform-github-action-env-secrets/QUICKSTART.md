# Quick Start Guide

Get up and running with `terraform-github-action-env-secrets` in 5 minutes.

## Prerequisites Checklist

- [ ] GitHub repository exists
- [ ] GitHub environment created (Settings → Environments → New environment)
- [ ] GitHub PAT token with `repo` permissions
- [ ] Terraform >= 1.9.8 installed

## Step 1: Create Environment in GitHub

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Environments**
3. Click **"New environment"**
4. Enter environment name (e.g., `production`)
5. Click **"Configure environment"** (optional: add protection rules)

## Step 2: Configure Provider

Create a `main.tf`:

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

Add to your `main.tf`:

```hcl
module "production_secrets" {
  source  = "c0x12c/action-env-secrets/github"
  version = "~> 1.0.0"

  repository  = "my-application"
  environment = "production"

  secrets = {
    "DATABASE_URL" = "postgresql://prod-db.example.com:5432/myapp"
    "API_KEY"      = "your-production-api-key"
  }
}
```

## Step 4: Define Variables

Create `variables.tf`:

```hcl
variable "github_token" {
  description = "GitHub PAT token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub org or username"
  type        = string
}
```

## Step 5: Set Your Token

**Option A: Environment Variable**
```bash
export TF_VAR_github_token="your-github-token"
export TF_VAR_github_owner="your-org"
```

**Option B: terraform.tfvars** (Don't commit this!)
```hcl
github_token = "your-github-token"
github_owner = "your-org"
```

## Step 6: Apply

```bash
# Initialize
terraform init

# Preview changes
terraform plan

# Apply changes
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
    environment: production  # Must match your environment name

    steps:
      - uses: actions/checkout@v4

      - name: Deploy with secrets
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          echo "Deploying with environment secrets"
          ./deploy.sh
```

## Verify It Works

1. Push your workflow to GitHub
2. Go to **Actions** tab
3. Trigger the workflow
4. Check that secrets are available (they won't show values)

## Common Issues

### "Environment not found"
- **Fix**: Create the environment in GitHub Settings → Environments

### "Resource not accessible"
- **Fix**: Ensure your token has `repo` permission

### Secrets not showing in workflow
- **Fix**: Add `environment: <name>` to your job

## Next Steps

- Add more environments (staging, development)
- Set up environment protection rules
- Rotate secrets periodically
- Explore advanced patterns in README.md

## Quick Reference

```hcl
# Minimal example
module "secrets" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "repo-name"
  environment = "env-name"
  secrets     = { "KEY" = "value" }
}

# Multiple environments
module "prod" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "repo"
  environment = "production"
  secrets     = var.prod_secrets
}

module "staging" {
  source      = "c0x12c/action-env-secrets/github"
  repository  = "repo"
  environment = "staging"
  secrets     = var.staging_secrets
}
```

## Security Reminder

⚠️ **NEVER** commit secrets to git:

```bash
# Add to .gitignore
echo "*.tfvars" >> .gitignore
echo "*.tfvars.json" >> .gitignore
```

## Need Help?

- 📚 Read the full [README.md](./README.md)
- 💡 Check [examples](./example/complete/)
- 🐛 Report issues in the repository
- 📖 Review [GitHub's documentation](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)

---

**You're all set! 🎉** Your environment secrets are now managed with Terraform.
