# Example: Complete usage of terraform-github-action-env-secrets

# Production environment secrets
module "production_secrets" {
  source = "../../"

  repository  = "my-application"
  environment = "production"

  secrets = {
    "AWS_ACCESS_KEY_ID"     = "AKIAIOSFODNN7EXAMPLE"
    "AWS_SECRET_ACCESS_KEY" = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    "DATABASE_URL"          = "postgresql://prod-db.example.com:5432/myapp"
    "API_KEY"               = "prod-api-key-12345"
    "REDIS_URL"             = "redis://prod-redis.example.com:6379"
  }
}

# Staging environment secrets
module "staging_secrets" {
  source = "../../"

  repository  = "my-application"
  environment = "staging"

  secrets = {
    "AWS_ACCESS_KEY_ID"     = "AKIAIOSFODNN7STAGING"
    "AWS_SECRET_ACCESS_KEY" = "stagingSecretKeyExample"
    "DATABASE_URL"          = "postgresql://staging-db.example.com:5432/myapp"
    "API_KEY"               = "staging-api-key-67890"
    "REDIS_URL"             = "redis://staging-redis.example.com:6379"
  }
}

# Development environment secrets
module "development_secrets" {
  source = "../../"

  repository  = "my-application"
  environment = "development"

  secrets = {
    "AWS_ACCESS_KEY_ID"     = "AKIAIOSFODNN7DEVTEST"
    "AWS_SECRET_ACCESS_KEY" = "devSecretKeyExample"
    "DATABASE_URL"          = "postgresql://dev-db.example.com:5432/myapp"
    "API_KEY"               = "dev-api-key-11111"
    "REDIS_URL"             = "redis://dev-redis.example.com:6379"
  }
}

# Output the created secret names for each environment
output "production_secrets" {
  description = "Production environment secret names"
  value       = module.production_secrets.secret_names
}

output "staging_secrets" {
  description = "Staging environment secret names"
  value       = module.staging_secrets.secret_names
}

output "development_secrets" {
  description = "Development environment secret names"
  value       = module.development_secrets.secret_names
}
