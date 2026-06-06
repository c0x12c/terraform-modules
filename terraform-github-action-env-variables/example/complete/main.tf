# Example: Complete usage of terraform-github-action-env-variables

# Production environment variables
module "production_variables" {
  source = "../../"

  repository  = "my-application"
  environment = "production"

  variables = {
    # Environment configuration
    "NODE_ENV"   = "production"
    "LOG_LEVEL"  = "error"
    "DEBUG_MODE" = "false"

    # API configuration
    "API_ENDPOINT" = "https://api.example.com"
    "API_VERSION"  = "v1"
    "API_TIMEOUT"  = "30000"

    # AWS configuration
    "AWS_REGION" = "us-east-1"
    "S3_BUCKET"  = "my-app-prod"

    # Application settings
    "MAX_RETRIES"    = "3"
    "CACHE_TTL"      = "3600"
    "FEATURE_FLAG_X" = "enabled"
  }
}

# Staging environment variables
module "staging_variables" {
  source = "../../"

  repository  = "my-application"
  environment = "staging"

  variables = {
    # Environment configuration
    "NODE_ENV"   = "staging"
    "LOG_LEVEL"  = "warn"
    "DEBUG_MODE" = "true"

    # API configuration
    "API_ENDPOINT" = "https://staging-api.example.com"
    "API_VERSION"  = "v1"
    "API_TIMEOUT"  = "30000"

    # AWS configuration
    "AWS_REGION" = "us-east-1"
    "S3_BUCKET"  = "my-app-staging"

    # Application settings
    "MAX_RETRIES"    = "5"
    "CACHE_TTL"      = "1800"
    "FEATURE_FLAG_X" = "enabled"
  }
}

# Development environment variables
module "development_variables" {
  source = "../../"

  repository  = "my-application"
  environment = "development"

  variables = {
    # Environment configuration
    "NODE_ENV"   = "development"
    "LOG_LEVEL"  = "debug"
    "DEBUG_MODE" = "true"

    # API configuration
    "API_ENDPOINT" = "https://dev-api.example.com"
    "API_VERSION"  = "v2-beta"
    "API_TIMEOUT"  = "60000"

    # AWS configuration
    "AWS_REGION" = "us-west-2"
    "S3_BUCKET"  = "my-app-dev"

    # Application settings
    "MAX_RETRIES"    = "10"
    "CACHE_TTL"      = "300"
    "FEATURE_FLAG_X" = "disabled"
  }
}

# Output the created variable names for each environment
output "production_variables" {
  description = "Production environment variable names"
  value       = module.production_variables.variable_names
}

output "staging_variables" {
  description = "Staging environment variable names"
  value       = module.staging_variables.variable_names
}

output "development_variables" {
  description = "Development environment variable names"
  value       = module.development_variables.variable_names
}
