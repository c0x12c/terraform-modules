# Complete Example

This example demonstrates how to use the `terraform-github-action-env-secrets` module to create environment-specific secrets for multiple GitHub environments.

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

3. **GitHub Token**: A personal access token with the following scopes:
   - `repo` (Full control of private repositories)
   - `admin:repo_hook` (Read and write repository hooks)

## Setup

1. Set your GitHub token as an environment variable:

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

This example creates secrets in three different environments for the same repository:

### Production Environment
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DATABASE_URL`
- `API_KEY`
- `REDIS_URL`

### Staging Environment
- Same secret names as production but with staging-specific values

### Development Environment
- Same secret names as production but with development-specific values

## Using Secrets in GitHub Actions

After running this example, you can use the secrets in your workflows:

```yaml
name: Deploy to Production

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

      - name: Configure AWS Credentials
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
          aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

      - name: Deploy Application
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          REDIS_URL: ${{ secrets.REDIS_URL }}
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          ./deploy.sh
```

## Clean Up

To remove all created secrets:

```bash
terraform destroy
```

## Security Notes

⚠️ **Important**: Never commit the `terraform.tfvars` file to version control if it contains sensitive information.

Add to your `.gitignore`:

```
terraform.tfvars
*.auto.tfvars
```

## Advanced Usage

### Using Sensitive Variables

For production use, store secrets in a secure location:

```hcl
variable "production_secrets" {
  type = map(string)
  sensitive = true
}

module "production_secrets" {
  source = "../../"

  repository  = "my-application"
  environment = "production"
  secrets     = var.production_secrets
}
```

Then pass secrets via environment variables or Terraform Cloud:

```bash
export TF_VAR_production_secrets='{"API_KEY":"secret-value"}'
```

### Dynamic Environments

Create secrets for multiple environments dynamically:

```hcl
locals {
  environments = {
    production = {
      "DATABASE_URL" = "prod-db-url"
    }
    staging = {
      "DATABASE_URL" = "staging-db-url"
    }
  }
}

module "env_secrets" {
  source   = "../../"
  for_each = local.environments

  repository  = "my-application"
  environment = each.key
  secrets     = each.value
}
```
