# Changelog

All notable changes to this project will be documented in this file.

## [1.3.0](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-eventbridge-slack-notification/v1.2.0...terraform-aws-eventbridge-slack-notification/v1.3.0) (2026-10-30)


### Features

* **ecs-application:** optional permissions boundary on the module's IAM roles ([#397](https://github.com/c0x12c/terraform-modules/issues/397)) ([3b05ef8](https://github.com/c0x12c/terraform-modules/commit/3b05ef86f7d87a5ce77c57fcb9e8d3806928161e))

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
