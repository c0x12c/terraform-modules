# Changelog

All notable changes to this project will be documented in this file.
## [1.2.3]() (2026-04-13)

### Fixes

- Fix MSK offline partitions monitor threshold validation

## [1.2.2]() (2026-04-13)

### Fixes

- Fix MSK active controller monitor recovery threshold validation

## [1.2.1]() (2026-04-13)

### Fixes

- Fix MSK active controller monitor recovery threshold for less-than comparison

## [1.2.0]() (2026-04-13)

### Features

* Add MSK (Amazon Managed Streaming for Apache Kafka) monitors: broker CPU, disk usage, offline partitions, active controller count

## [1.1.1]() (2025-12-08)

### Features

* Add read throttle monitor for Kinesis

## [1.1.0]() (2025-09-15)

### Features

* Add monitors for data services (airflow, emr, kinesis)

## [1.0.0]() (2025-06-26)

### Features

* Add Database Name filter for monitoring and alert for that Database only. That will support to separate the notifications each database in the same account to each channel we want.
* Bump version to 1.0.0

## [0.2.0]() (2025-06-20)

### Changes

* Update Datadog Monitor Module Source to Terraform Registry.

## [0.1.80]() (2025-03-13)

### Fix Bugs

* Remove `elasticache_cache_errors` for elasticache monitor, which was not neccessary

## [0.1.38]() (2024-01-07)

### Features

* Update `renotify_occurrences` for each default services

## [0.1.36]() (2024-01-05)

### Features

* Remove unused variables `dd_users`.

## [0.1.32]() (2024-12-31)

### Fixes

* Add a default value for Terraform try functions

## [0.1.30]() (2024-12-30)

### Features

* Initial commit with all the code
