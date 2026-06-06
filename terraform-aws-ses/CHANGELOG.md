# Changelog

All notable changes to this project will be documented in this file.
## [1.0.0]() (2025-08-22)

### BREAKING CHANGES

* Separate module to registry module
* Add emails arn to policy to allow role could take action on email

## [0.2.1]() (2025-06-18)

### Changes

* Add new outputs for domain and email identity IDs.

## [0.2.0]() (2025-06-18)

### Removed

* Remove outgoing email logs and Datadog integrations.

## [0.1.81]() (2025-03-13)

### Features

* Add the Lambda function to log the SES Outgoing Emails to the Datadog

## [0.1.53]() (2025-01-13)

### Features

* Handle reading the aws_route53_zone to publish dkim or mx records

## [0.1.46]() (2025-01-09)

### Features

* Add variable `enabled_ses_identity_policy` to make ses_identity_policy optional.

## [0.1.39]() (2025-01-08)

### Features

* Add DKIM records and MX records options.

## [0.1.21]() (2024-12-24)

### Features

* Add prefix to verify domain
* Rename `use_route53` to `verify_domain` for more information

## [0.1.7]() (2024-12-09)

### Features

* Fix the SES module

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.3]() (2024-12-04)

### Features

* Initial commit with all the code
