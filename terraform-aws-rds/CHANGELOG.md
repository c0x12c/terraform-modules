# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-rds/v0.7.0...terraform-aws-rds/v1.0.0) (2026-08-11)


### ⚠ BREAKING CHANGES

* **rds:** `allow_major_version_upgrade` now defaults to `false` (was `true`). Anyone relying on the module to perform major engine upgrades implicitly must now set it to `true` explicitly. The old default inverted AWS's own, and contradicted `auto_minor_version_upgrade` in this same module, which has always defaulted to `false` for the far less disruptive operation.
* **rds:** `engine_version` now defaults to `18.4` (was `16.4`, which AWS has retired - every greenfield create on the old default failed at `CreateDBInstance`).

  Together these mean a consumer who sets neither variable gets a **failed apply** rather than an unplanned in-place Postgres 16 to 18 upgrade. A major upgrade takes the instance offline for its duration and is not reversible without a restore, so failing is the correct outcome for something nobody asked for. See "Upgrading to 1.0.0" in the module README for how to pin your current version, and how to perform a major upgrade deliberately.

### Features

* **rds:** master password rotation - on-demand trigger and managed-secret schedule ([#263](https://github.com/c0x12c/terraform-modules/issues/263)) ([42cf657](https://github.com/c0x12c/terraform-modules/commit/42cf657cf521fd9655d0e29e8d0ee6876e8ee21d))
* **rds:** default `engine_version` to 18.4 ([#263](https://github.com/c0x12c/terraform-modules/issues/263))
* **rds:** default `allow_major_version_upgrade` to false ([#263](https://github.com/c0x12c/terraform-modules/issues/263))

## [0.7.0](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-rds/v0.6.7...terraform-aws-rds/v0.7.0) (2026-07-22)


### Features

* **terraform-aws-rds:** AWS-managed master password rotation ([#237](https://github.com/c0x12c/terraform-modules/issues/237)) ([581ef6d](https://github.com/c0x12c/terraform-modules/commit/581ef6d90532269f197782a5279f17baa25a57f2))

## [0.6.7](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-rds/v0.6.6...terraform-aws-rds/v0.6.7) (2026-07-04)


### Bug Fixes

* **terraform-aws-rds:** enable IAM DB auth on read replicas ([#217](https://github.com/c0x12c/terraform-modules/issues/217)) ([1d558c9](https://github.com/c0x12c/terraform-modules/commit/1d558c9b3a85261f8f0a8b04a3661961fe3f4d07))

## [0.6.6]() (2025-06-06)

### Features

* Add `enabled_cloudwatch_logs_exports` to enable logging on RDS instance and replicas.

## [0.6.2]() (2025-06-02)

### Changes

* Add `db_port` output to RDS module.

## [0.6.0]() (2025-05-26)

### Features

* Add variable `primary_deletion_protection` and `replica_deletion_protection` to manage `deletion_protection` status on primary and replicas.

## [0.5.2]() (2025-04-25)

### Features

* Add variable `multi-az` to indicate whether the database instance should be deployed across multiple availability zones

## [0.1.79]() (2025-03-12)

### Features

* Add variable `use_secret_manager` and `secret_manager_db_password_name` to create Secret Manager for database password
  management.
* Add variable `password_length` to custom database password length.
* Add variable `db_subnet_group_name` for migration purpose.
* Add variable `additional_postgres_parameters` for additional parameters on PostgreSQL instance.

### Bug fixes

* Correct `copy_tags_to_snapshot` input to submodule `db_instance`.

## [0.1.75]() (2025-03-07)

### Features

* Rename module to `rds`
* Rewrite the code to support multiple RDS engines

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.1]() (2024-11-29)

### Features

* Refactor RDS module to make it generally

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code
