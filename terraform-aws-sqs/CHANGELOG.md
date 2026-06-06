# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0]() (2025-12-29)

### Breaking changes
* Update the default `principal_roles`, remove the wide access `*`

### Features

* Update module source to Terraform Registry format (c0x12c/sqs/aws)
* Add `enabled_dlq_queue_policy` variable to optionally enable dead letter queue policy
* Add separate IAM policy document and queue policy resources for DLQ

## [0.2.4]() (2025-07-07)

### Features

* Add sqs list queue policies

## [0.2.3]() (2025-03-24)

### Features

* Set IAM policy document version

## [0.1.80]() (2025-03-13)

### Features

* Add attribute `content_based_deduplication` to `aws_sqs_queue.queue`.

## [0.1.45]() (2025-01-09)

### Features

* Change `max_receive_count` type to number.
* Separate `aws_sqs_queue.queue.redrive_policy` to `aws_sqs_queue_redrive_policy.this`.
* Add attribute `redrive_allow_policy` to `aws_sqs_queue.dlq`.

## [0.1.37]() (2025-01-06)

### Features

* Add variable `enabled_dead_letter_queue` to optionally disable dlq
* Add variable `enabled_read_write_policy` and `read_write_policy_name` to optionally configure a read-write policy

## [0.1.28]() (2024-12-26)

### Features

* Make read/write policy's name customizable via variables `read_policy_name` and `write_policy_name`.

## [0.1.20]() (2024-12-24)

### Features

* Refactor components.
* Update policies Send Receive resources principal to created queue only.
* Update policy Receive with 2 additional permissions: "sqs:DeleteMessage", "sqs:GetQueueAttributes".
* Remove redundant policy in aws_sqs_queue.queue.

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code

