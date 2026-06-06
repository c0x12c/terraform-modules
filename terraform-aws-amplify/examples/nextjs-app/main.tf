module "website" {
  source = "../../"

  dns_zone         = "example.com"
  environment      = "dev"
  repository       = "https://github.com/example-org/example-repo"
  application_root = "./"
  build_variables = {
    NEXT_PUBLIC_DOMAIN = "https://test.example.com"
    NEXT_PUBLIC_ENV    = "dev"
  }
  github_token             = "example"
  deploy_branch_name       = "master"
  sub_domain               = "test"
  name                     = "example"
  install_command          = "yarn install"
  build_command            = "yarn build"
  base_artifacts_directory = ".next"

  # Security headers configuration
  custom_headers = [
    {
      pattern = "**/*"
      headers = [
        {
          key   = "Strict-Transport-Security"
          value = "max-age=63072000; includeSubDomains; preload"
        },
        {
          key   = "X-Content-Type-Options"
          value = "nosniff"
        },
        {
          key   = "X-Frame-Options"
          value = "DENY"
        },
        {
          key   = "X-XSS-Protection"
          value = "1; mode=block"
        },
        {
          key   = "Referrer-Policy"
          value = "strict-origin-when-cross-origin"
        }
      ]
    },
    {
      pattern = "*.html"
      headers = [
        {
          key   = "Content-Security-Policy"
          value = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:;"
        }
      ]
    },
    {
      pattern = "*.{jpg,jpeg,png,gif,svg}"
      headers = [
        {
          key   = "Cache-Control"
          value = "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
