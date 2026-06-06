# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1]() (2025-07-10)

### Changes
* Update example usage in README to reflect the new module name.

## [1.0.0]() (2025-06-24)

### BREAKING CHANGES

* Rename module to `oidc-provider`.


## [0.1.70]() (2024-02-27)

### Bug fixes

* Fix `aws_iam_openid_connect_provider` resource creation using `length` instead of `try` to resolve error that `data source is evaluated only at apply time`.

## [0.1.40]() (2024-01-08)

### Bug fixes

* Remove create `var.create_provider` from `tls_certificate` to prevent bugs.

## [0.1.39]() (2024-01-08)

### Bug fixes

* Update `var.create_provider` for `aws_iam_openid_connect_provider` to prevent bugs from not found

## [0.1.21]() (2024-12-24)

### Features

* Move and generalize module `provider` to [(aws/oidc/provider)](../provider).
