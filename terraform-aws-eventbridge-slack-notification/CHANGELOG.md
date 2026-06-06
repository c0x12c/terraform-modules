# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0]() (2026-03-01)

### Features

* Update default Lambda runtime from `nodejs20.x` to `nodejs22.x`

## [1.1.0]() (2025-10-14)

### Features

* Improve EventBridge rule configuration flexibility.
* Optimize resource naming conventions for better clarity.

## [1.0.0]() (2025-10-14)

### Features

* Initial release of reusable EventBridge Slack notification module
* Support for multiple EventBridge rules with single Lambda function
* Customizable Lambda handler, runtime, and environment variables
* Support for additional IAM policies for service-specific permissions
* Generic notification system that works with any AWS service events
