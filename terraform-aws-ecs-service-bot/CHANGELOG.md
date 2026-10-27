# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-ecs-service-bot/v0.1.0...terraform-aws-ecs-service-bot/v0.2.0) (2026-10-27)


### Features

* **ecs-application:** scope execution-role secret and SSM reads to caller-supplied ARNs ([#384](https://github.com/c0x12c/terraform-modules/issues/384)) ([660e7c6](https://github.com/c0x12c/terraform-modules/commit/660e7c6eae65404ca9e473eb74f3ca672c1358c3))

## [0.1.0]() (2026-01-12)

### Added

* Initial implementation of ECS Service Bot module.
* Deploys Service Bot using `c0x12c/ecs-application/aws` module.
