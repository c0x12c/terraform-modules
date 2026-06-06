# Changelog

All notable changes to this project will be documented in this file.

## [1.1.1]() (2026-04-22)

### Fix

* Add missing variables `default_cache_behavior` and `ordered_cache_behaviors`.

## [1.1.0]() (2026-04-22)

### Features

* Add `function_association` support to `default_cache_behavior` and `ordered_cache_behaviors` in the CloudFront module.

## [1.0.0]() (2025-07-02)

### ⚠ BREAKING CHANGES

* Fix bucket policy overwrites.

## [0.7.1]() (2025-06-18)

### Changes

* Add variable `versioning_status`.

## [0.7.0]() (2025-06-17)

### Changes

* Replaced local S3 module source with public module from Terraform Registry.

## [0.6.7]() (2025-06-10)

### Features

* Add output `cloudfront_distribution_arn`.

## [0.6.4]() (2025-06-03)

### Removed

* Removes duplicate S3 bucket policy creation in [./s3.tf](./s3.tf).

## [0.6.3]() (2025-06-02)

### Changes

* Enable HTTP access for S3 bucket in CloudFront setup.

## [0.3.16]() (2025-04-14)

### Features

* Add `use_wildcard_domain` to add the wildcard route53 to cloudfront

## [0.3.8]() (2025-04-07)

### Features

* Add `s3_redirect_domain` to configure addressed S3 bucket to redirect to another domain

## [0.1.72]() (2025-03-05)

### Features

* Add wafv2 arn for clound front

## [0.1.66]() (2025-02-11)

### Features

* Add response header configuration option for cloud front

## [0.1.64]() (2025-01-24)

### Features

* Update cloudfront module to support root domain.

## [0.1.47]() (2025-01-09)

### Features

* Add `ordered_cache_behaviors` to custom `aws_cloudfront_distribution.ordered_cache_behavior`.

## [0.1.41]() (2025-01-09)

### Features

* Add `bucket_prefix`, `s3_custom_readonly_policy_name`, `s3_custom_read_write_policy_name`,
  `s3_readonly_policy_description`, `s3_read_write_policy_description` to avoid resource recreation.

## [0.1.37]() (2025-01-06)

### Features

* Add `override.tofu` to override Terraform version constrain with OpenTofu

## [0.1.28]() (2024-12-27)

### Features

* Add a flag to enable www domain: `use_www_domain`
* Add `cloudfront_distribution_aliases` variable to custom distribution aliases
* Add `existing_s3_bucket_name` variable to specify the name of custom s3 bucket to use

## [0.1.17]() (2024-12-23)

### Features

* Update aws_cloudfront_distribution.aliases.
* Add variables `domain_name` to root module and sub-module `cloudfront`.
* Add variables `enabled_read_write_policy`, `enabled_read_only_policy` to root module and to s3 module.

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.2]() (2024-12-04)

### Features

* Use HTTP to HTTPS policy to all behaviors

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code
