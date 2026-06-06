# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0]() (2026-05-11)

### Features

* `custom_bucket_policy` (DEPRECATED) — the existing single-statement variable is kept for backwards compatibility but
  will be removed in a future release. Migrate to `custom_bucket_policies` as soon as possible.
* `custom_bucket_policies` (NEW) — accepts `list(object({...}))`, allowing multiple bucket policy statements to be
  defined in a single call. Both `custom_bucket_policy` and `custom_bucket_policies` are merged at apply time, so
  callers can migrate incrementally. To supply more than one statement, add additional objects to the list.

## [1.1.0]() (2025-07-02)

### ⚠ BREAKING CHANGES

* Remove `access-logging` sub-module, remove variable `enabled_access_logging`.
* Fix bucket policy overwrites.

## [1.0.0]() (2025-06-24)

### ⚠ BREAKING CHANGES

* Separate S3 to a single module
* Add `custom_bucket_policy` create additional bucket policy, which support other feature could access this bucket. For
  example, we can define `logdelivery.elasticloadbalancing.amazonaws.com` in principals field to allow elb write logs to
  our bucket.

## [0.4.0]() (2025-04-16)

### ⚠ BREAKING CHANGES

* Update `aws_s3_bucket_policy` with creation flag `create_bucket_policy`.

## [0.3.17]() (2025-04-15)

### Features

* Add S3 lifecycle configuration `s3_lifecycle_rules`.

## [0.3.14]() (2025-04-11)

### Features

* Restrict HTTP access to S3 bucket via `disabled_s3_http_access`.

## [0.1.68]() (2025-02-20)

### Features

* Add `read_write_actions` which allow s3 policy can be added permissions base on requirement of projects

## [0.1.57]() (2025-01-15)

### Bug fixes

* Correct access-log-policy resource (use bucket arn instead of id)

## [0.1.56]() (2025-01-14)

### Features

* Add a submodule `access-log-policy` to configure bucket policy to allow AWS services to write access logs from other
  services/buckets.

## [0.1.55]() (2025-01-14)

### Features

* Add variable `enabled_access_logging` and `access_log_target_bucket_id` to optionally configure access logging for the
  bucket.

## [0.1.36]() (2024-01-06)

### Features

* Add variables to avoid forced resource replacements during rollout: `custom_readonly_policy_name`,
  `custom_read_write_policy_name`.

## [0.1.27]() (2024-12-26)

### Features

* Add variables to avoid forced resource replacements during rollout: `read_write_policy_description`,
  `read_write_policy_name_prefix`, `readonly_policy_description`, `readonly_policy_name_prefix`,
  `public_policy_description`, and `public_policy_name_prefix`.

## [0.1.24]() (2024-12-26)

### Features

* Add attribute `expose_headers` to variable `cors_configuration`.

## [0.1.18]() (2024-12-23)

### Features

* Add output `iam_policy_s3_bucket_assets_read_write_arn`.

## [0.1.15]() (2024-12-19)

### Features

* Add variable `acl` and resource `aws_s3_bucket_acl`.

## [0.1.12]() (2024-12-17)

### Features

* Add attribute `force_destroy` for s3 bucket
* Add `read_write_policy`

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code

