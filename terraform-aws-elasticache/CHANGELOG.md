# Changelog

All notable changes to this project will be documented in this file.

## [0.7.0](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-elasticache/v0.6.0...terraform-aws-elasticache/v0.7.0) (2026-06-20)


### Features

* Add `cluster_mode_enabled` variable (default `true`). When `false`, provisions a Cluster Mode Disabled (standalone) replication group via `num_cache_clusters = 1 + replicas_per_node_group` instead of `num_node_groups`, enabling multi-key Redis operations without CROSSSLOT errors. Use a non-cluster parameter group when disabled.
* Reflect the topology in the replication group `description` (`redis cluster` vs `redis (standalone)`).

### Bug Fixes

* Derive the parameter-group family from the engine (`valkey8`/`redis7`) instead of hardcoding `redis`, so Valkey clusters using `custom_redis_parameters` get the correct family.
* Force `multi_az_enabled` / `automatic_failover_enabled` to `false` for a single-node standalone group (no replicas), which AWS otherwise rejects. Cluster-mode behavior is unchanged.

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
