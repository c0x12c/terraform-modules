# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-10-09

### Changed
- Set `create_environment` default to `true` to create GitHub environment.

## [1.0.0] - 2025-01-XX

### Added
- Initial release of terraform-github-action-env-variables module
- Support for creating GitHub Actions environment variables
- Environment-scoped variable management (production, staging, development)
- Batch variable creation via map input
- Outputs for tracking created variables
- Comprehensive documentation with examples
- Support for multiple environments
- Integration examples with GitHub Actions workflows

### Features
- `github_actions_environment_variable` resource for environment-specific variables
- Non-sensitive configuration value management
- Complete example with three environments
- README with usage patterns, best practices, and security guidance
- Comparison with secrets and repository-level variables

### Documentation
- Detailed README with multiple usage examples
- Complete example implementation
- Troubleshooting guide
- Migration guide from repository variables
- Security best practices and guidelines
