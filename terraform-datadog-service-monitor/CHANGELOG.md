# Changelog

All notable changes to this project will be documented in this file.

## [1.0.2](https://github.com/c0x12c/terraform-modules/compare/terraform-datadog-service-monitor/v1.0.1...terraform-datadog-service-monitor/v1.0.2) (2026-06-09)


### Bug Fixes

* partial override_default_monitors in service-monitor ([#147](https://github.com/c0x12c/terraform-modules/issues/147)) ([312a905](https://github.com/c0x12c/terraform-modules/commit/312a905f99d239c0ec0924059afc9533efb6159e))

## [1.1.1]() (2026-06-09)

### Bug Fixes

* Fix `override_default_monitors` so partial overrides work. Every attribute is `optional()` with no default, so omitted attributes resolved to `null` and the `merge(config, override)` in `service_monitor.tf` / `resource_monitor.tf` clobbered each default monitor's `title`, `query_template`, etc. Null-valued override attributes are now stripped before merging, so callers can override only the fields they need (for example, just `threshold_critical` and `threshold_critical_recovery` on `p95`) while keeping the rest of the module defaults.

## [1.1.0]() (2025-08-11)

### Feature

* Add the variable `var.restart_on_missing_data` to manage the state when there is no change. When the restart value increases to 1 and then returns to 0, the alert does not recover because the recovery threshold requires a value below 0, while the alert threshold is >= 1. Therefore, when the value is 0, the monitor does not recover. The on missing data will fix it whenever the data is at 0.

## [1.0.1]() (2025-08-11)

### Feature

* Change pods restart recovery threshold from < 0 to < 0.5

## [1.0.0]() (2025-07-21)

### Feature

* Pump version to 1.0.0
* Customize the query field from p95 metrics, request hit and error hit

## [0.7.1]() (2025-07-21)

### Features

* Update to use c0x12c/monitors/datadog version 1.0.0
* Add override_default_message to change default alert messages

## [0.7.0]() (2025-07-10)

### Breaking changes

* Modify the Datadog restart monitor to use the change() function, following the Datadog example.

## [0.6.0]() (2024-06-20)

### Changes

- Update Datadog Monitor Module Source to Terraform Registry.

## [0.5.1]() (2024-04-24)

### Breaking changes

* Modify the Datadog restart monitor to use the diff function, which captures only new restart events. When a pod restarts, the query returns a value of 1, and it falls back to 0 if no further restarts occur.

## [0.1.36]() (2024-01-05)

### Features

* Initial commit with all the code
