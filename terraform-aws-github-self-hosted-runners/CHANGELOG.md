# Changelog

All notable changes to this project will be documented in this file.

## [0.1.66]() (2025-02-06)

### Features
- Update Terraform installation to allow version suffix support

## [0.1.65]() (2025-02-06)

### Features
- Introduced resources for creating a custom AMI from a source instance
- Updated configurations to utilize the new custom AMI for launch templates.

## [0.1.61]() (2025-01-21)

### Features
- Add variable `update_default_launch_template_version` to allowed update the default launch template version automatically (default = true)
- Rename variable `vpc_zone_identifier` to `subnet_ids`

## [0.1.59]() (2025-01-21)

### Features

- Initial implementation of Github Actions Self Hosted Runner on AWS EC2
