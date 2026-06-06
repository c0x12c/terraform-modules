# Changelog

All notable changes to this project will be documented in this file.

## [0.8.0]() (2025-12-29)

### BREAKING CHANGES

* Changed `email` variable to `emails` to support multiple email addresses for SNS topic subscriptions. This now accepts a list of strings instead of a single string.

### Features

* Add support for multiple email subscriptions to SNS topic.
* Update module source reference in README to use Terraform Registry format (`c0x12c/cloudwatch-alarm/aws`).

## [0.7.0]() (2025-06-16)

### BREAKING CHANGES

* Changed module name to `cloudwatch-alarm` for Terraform Registry discovery compatibility.

### Features

* Add outputs.tf file

## [0.3.13]() (2025-04-10)

### Features

* Add RDS namespace `identifier`.

## [0.1.62]() (2025-01-24)

### Features

* Extended CloudWatch alarm configuration to support EC2 AutoScalingGroup

## [0.1.59]() (2025-01-20)

### Features

* Extended CloudWatch alarm configuration to include `Currency` and `LinkedAccount` dimensions for AWS/Billing
  namespace.

## [0.1.33]() (2025-01-02)

### Feature

* Ensure InstanceId is included when the namespace is "AWS/EC2".

## [0.1.11]() (2024-16-09)

### Features

* Initialized module for CloudWatch Alarm
