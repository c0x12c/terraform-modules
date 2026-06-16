# Changelog

All notable changes to this project will be documented in this file.

## [0.7.0]() (2026-06-16)

### Features

* Added `centralized_release_slack_channel` variable to configure the centralized Slack channel for trunk-based single-channel releases (`CENTRALIZED_RELEASE_SLACK_CHANNEL`).

### Chore

* Updated default service bot image tag to `v1.0.0`.

## [0.6.1]() (2025-12-17)

### Chore

* Updated default service bot image tag to `v0.3.0`.

## [0.5.0]() (2025-12-16)

### Features

* Migrated from GitHub Personal Access Token (PAT) to GitHub App authentication for improved security and permissions management.

### Refactoring

* Replaced `github_login` and `github_pat` variables with `github_app_id`, `github_app_installation_id`, and `github_app_private_key` for GitHub App authentication.
* Updated default service bot image tag to `v0.2.0`.

### Breaking Changes

* **GitHub Authentication**: The module now requires GitHub App credentials instead of PAT. Users must update their configuration to provide `github_app_id`, `github_app_installation_id`, and `github_app_private_key` instead of `github_login` and `github_pat`.

## [0.4.0]() (2025-12-12)

### Fix Bugs
* Move `create_kubernetes_namespace` out of `service` because it's a variables of `eks-service`

## [0.3.0]() (2025-12-12)

### Version Updating
* Increase `helm` version require for terraform, which may conflicts with other modules due to our modules are all `~> 3.0`.

## [0.2.0]() (2025-12-09)

### Refactoring

* Renamed `micronaut_env` variable to `environment`.

### Chore

* Updated Terraform required version to `>= 1.10`.

## [0.1.0]() (2025-12-09)

### Features

* Initial implementation of Service Bot module.
* Deploys Service Bot using Helm chart `spartan`.
* Configures EKS service with `c0x12c/eks-service/aws`.
* Sets up integrations for Slack, GitHub, Jenkins, and Atlassian.
* Supports external secrets and config maps.
