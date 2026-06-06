# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2025-10-23

### Fixed

- Fixed `resources_to_ignore` variable validation to properly handle null values.

## [1.1.0] - 2024-10-22

### Added

- **New Configuration Options**: Added support for all official Reloader configuration options:
  - `auto_reload_all` - Auto-reload all resources
  - `is_argo_rollouts` - Argo Rollouts support
  - `is_openshift` - OpenShift deployment support
  - `ignore_secrets` - Ignore secrets
  - `ignore_configmaps` - Ignore configmaps
  - `ignore_jobs` - Ignore Job workloads
  - `ignore_cronjobs` - Ignore CronJob workloads
  - `reload_on_create` - Reload on create
  - `reload_on_delete` - Reload on delete
  - `sync_after_restart` - Sync after restart
  - `enable_ha` - High availability support
  - `read_only_root_filesystem` - Read-only root filesystem
  - `enable_metrics_by_namespace` - Prometheus metrics by namespace

### Changed

- **Updated Image Configuration**: 
  - Changed image repository from `stakater/reloader` to `ghcr.io/stakater/reloader`
  - Updated default image tag from `v1.0.106` to `v1.4.8`
  - Updated chart version from `1.0.106` to `1.4.8`
- **Enhanced Reload Strategy**: Added support for `default` strategy alongside `env-vars` and `annotations`
- **Expanded Log Levels**: Added support for `trace`, `warning`, `fatal`, and `panic` log levels
- **Updated Values Structure**: Restructured locals.tf to match official Reloader chart format
- **Improved Examples**: Updated advanced example to showcase new configuration options

### Fixed

- **Configuration Alignment**: Fixed all configuration values to match official Stakater Reloader values.yaml
- **Validation Rules**: Corrected validation rules for reload strategy and log levels
- **Documentation**: Updated README with all new variables and corrected defaults

## [1.0.0] - 2024-10-22

### Added

- Initial release of the Terraform Kubernetes Helm Reloader module
- Support for deploying Stakater Reloader using Helm
- Namespace creation with custom labels and annotations
- Support for all Reloader configuration options including:
  - Reload strategies (env-vars, annotations)
  - Resource filtering (ConfigMaps, Secrets, workload types)
  - Namespace filtering and selection
  - Annotation key overrides
  - Logging configuration
  - Debugging options (pprof)
- Resource configuration (requests, limits, node selector, tolerations, affinity)
- Security context configuration
- Comprehensive examples (basic, advanced, GitOps)
- Complete documentation with usage examples

### Features

- **Reload Strategies**: Support for both env-vars and annotations strategies
- **Resource Filtering**: Filter by resource types, workload types, and labels
- **Namespace Management**: Global watching or selective namespace filtering
- **Security**: Configurable security contexts (RBAC managed by Helm chart)
- **Observability**: JSON logging and pprof support
- **GitOps Ready**: Annotations strategy prevents config drift in ArgoCD/Flux
- **Production Ready**: Resource limits, node selection, and high availability support
- **Simplified Architecture**: Only creates namespace, lets Helm chart handle all other resources
