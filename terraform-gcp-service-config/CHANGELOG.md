# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0]() (2025-07-15)

### BREAKING CHANGES

* Move module to `c0x12c` GitHub Org and deploy module to Terraform Registry.
* Update module source and dependency in README.

## [0.1.56]() (2025-01-15)

### Fixed Bugs

* Fixed a bug where the variable `project_id` is redundant and vulnerable.

## [0.1.6]() (2024-12-08)

### Fixed Bugs

* Fixed a bug where the output `dns_record_name` could be null if the `managed_zone` was not specified.
* Fixed a bug that prevented the creation of the DNS record set due to an incorrect DNS name value.

## [0.1.5]() (2024-12-06)

### Features

* Initial commit with all the code

