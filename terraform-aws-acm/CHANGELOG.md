# Changelog

All notable changes to this project will be documented in this file.

## [0.1.63]() (2025-06-18)

### Changes

* Add dependabot configuration for GitHub Actions and Terraform.

## [0.1.62]() (2025-01-24)

### Features

* Fix `validation_record_fqdns` value in `aws_acm_certificate_validation`.

## [0.1.12]() (2024-12-17)

### Features

* Update `var.zone_id` default value to null.
* Update conditions to create `aws_route53_record` and `aws_acm_certificate_validation` only if (and) `var.zone_id` is
  not null.

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code
