# Changelog

All notable changes to this project will be documented in this file.

## [1.1.1](https://github.com/c0x12c/terraform-modules/compare/terraform-datadog-mono-monitor/v1.1.0...terraform-datadog-mono-monitor/v1.1.1) (2026-07-23)


### Bug Fixes

* **datadog-monitors:** allow disabling renotify via renotify_interval = 0 ([#239](https://github.com/c0x12c/terraform-modules/issues/239)) ([18ad55e](https://github.com/c0x12c/terraform-modules/commit/18ad55e6c84ac67a5f2927485dc746e76fd5b113))

## [1.1.0]() (2025-06-26)

### Features

* Update c0x12c/monitors/datadog requirement from ~> 0.1.38 to ~> 1.0.0
* Add overwrite default message in override_default_monitors

## [1.0.0]() (2025-06-26)

### Features

* Add Kube Namespace filter for monitoring and alert for that namespace only. That will support to separate the notifications each service in the same cluster to each channel we want.
* Bump version to 1.0.0

## [0.2.0]() (2025-06-20)

### Changes

* Update Datadog Monitor Module Source to Terraform Registry.

## [0.1.36]() (2024-01-05)

### Features

* Initial commit with all the code
