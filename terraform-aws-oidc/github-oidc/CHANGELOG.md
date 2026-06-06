# Changelog

All notable changes to this project will be documented in this file.

## [0.1.70]() (2024-02-27)

### Bug fixes

* Fix `aws_iam_openid_connect_provider` resource creation using `length` instead of `try` to resolve error that `data source is evaluated only at apply time`.

## [0.1.21]() (2024-12-24)

### Features

* Add provider `tls` version constraints.
* Replace `var.aws_account_id` with `data.aws_caller_identity` to use runtime AWS identity.
* Add variables: `additional_thumbprints`, `client_id_list`, `url`, `create_provider`.
* Add outputs: `provider_arn`, `provider_url`, `github_tf_ops_role_arn`.

## [0.1.12]() (2024-12-17)

### Features

* Initial commit with all the code
