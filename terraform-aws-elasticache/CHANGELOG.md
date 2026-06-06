# Changelog

All notable changes to this project will be documented in this file.

## [0.6.0]() (2025-05-27)

### Changes

* Add `engine` variable to support different Redis engines.

## [0.4.1]() (2025-04-16)

### Features

* Add `custom_redis_parameters` to support custom redis parameters.

## [0.3.10]() (2025-04-09)

### Bug Fixes

* Add `replicas_per_node_group` to support multi-az.

## [0.3.8]() (2025-04-08)

### Features

* Add `transit_encryption_mode` to `aws_elasticache_replication_group`.

## [0.3.4]() (2025-04-03)

### Features

* Add `at_rest_encryption_enabled` to specify disk encryption.

## [0.1.54]() (2025-01-13)

### Bug Fixes

* Fix `auth_token` is enabled if `transit_encryption_enabled` is true

## [0.1.43]() (2025-01-09)

### Features

* Add output `elasticache_replication_group_configuration_endpoint_address` and variable `transit_encryption_enabled`.

## [0.1.24]() (2024-12-26)

### Features

* Add output `elasticache_replication_group_configuration_endpoint_address`.

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code
