# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-eks-service/v0.2.8...terraform-aws-eks-service/v0.3.0) (2026-10-16)


### Features

* **terraform-aws-eks-service:** add create_secret to skip the env Secret ([#378](https://github.com/c0x12c/terraform-modules/issues/378)) ([e41253b](https://github.com/c0x12c/terraform-modules/commit/e41253b0e44a17c2d188526e167620edc05bf55f))

## [0.2.8]() (2025-10-03)

### Features

* Introduced sub-field `resources` in `assume_custom_roles` to allow flexible customization of role assumptions.

## [0.2.7]() (2025-10-03)

### Features

* Introduced `assume_custom_roles` to allow flexible customization of role assumptions.

## [0.2.6]() (2025-03-29)

### Bug fixes

* Fix EKS service account annotations

## [0.1.71]() (2025-03-03)

### Bug fixes

* Fix EKS service account namespace reference

## [0.1.60]() (2025-01-22)

### Features

* Add variable `keda_arn` to set keda irsa role arn.

## [0.1.26]() (2024-12-26)

### Features

* Add output `service_hostnames` to generates a map of service hostnames by iterating over the Route 53 records and
  extracting their fully qualified domain names (FQDNs)

## [0.1.24]() (2024-12-26)

### Features

* Add `var.create_kubernetes_namespace` to specify whether to create a namespace
* Add `var.config_map_env_var_name` to overwrite default kubernetes_config_map name
* Add `var.secret_env_var_name` to overwrite default kubernetes_secret secret env var name

## [0.1.22]() (2024-12-25)

### Features

* Initial commit with all the code
