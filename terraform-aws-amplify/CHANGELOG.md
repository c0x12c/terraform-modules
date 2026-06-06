# Changelog

All notable changes to this project will be documented in this file.

## [1.4.2]() (2026-04-24)

### Features

* Bump GitHub provider version

## [1.4.1]() (2026-03-31)

### Bug Fixes

* Replace regex-based monorepo detection with explicit string normalization to avoid runtime errors
* Use normalized `application_root` consistently in custom headers and build spec templates

## [1.4.0]() (2026-03-01)

### Features

* Update Lambda runtime from `nodejs20.x` to `nodejs22.x`

## [1.3.2]() (2026-01-18)

### Bug Fixes

* Fixed `custom_headers` always showing changes in Terraform plan by using `jsonencode` instead of YAML format for the `custom_headers_yaml` local.

## [1.3.1]() (2026-01-18)

### Bug Fixes

* Replaced local-exec and null_resource approach with native `custom_headers` argument in `aws_amplify_app` resource.

## [1.3.0]() (2026-01-18)

### Features

* Added `custom_headers` variable to support custom HTTP headers for Amplify applications.

## [1.2.0]() (2025-12-11)

### Features

* Added explicit source for GitHub provider (`integrations/github`) in versions.tf

## [1.1.1]() (2025-09-05)

### Features

* Enhanced markdown formatting in commit message by removing unnecessary backticks

## [1.1.0]() (2025-09-05)

### Features

* Enhanced Slack notification Lambda function to show proper Amplify app name instead of app ID.
* Removed Job ID and Status fields from Slack notifications for cleaner messaging.
* Added GitHub commit subject display in notifications.
* Added associated domain name display for Amplify apps.
* Updated Lambda function to use AWS SDK v3 for better Amplify API integration.

## [1.0.2]() (2025-09-04)

### Features

* Add outputs for Amplify app ID

## [1.0.1]() (2025-07-03)

### Features

* Add `enable_auto_build` to handle flag for enabled auto build or not, in case we don't want production to auto build from master.

## [1.0.0]() (2025-07-03)

### Features

* Add `enabled_notification` to enable notification which send messages through webhook to Slack
* Add `slack_webhook_url` add slack webhook which will handle messages

## [0.1.22]() (2024-12-05)

### Features

* Add `var.enable_backend` to enable backend or use frontend format only
* Add `aws_amplify_webhook` to provides an Amplify Webhook resource

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code
