# Changelog

All notable changes to this project will be documented in this file.

## [0.5.0]() (2025-04-21)

### Features

* Add VPC Network ACLs rules with variable `custom_acls`.

## [0.1.69]() (2025-02-21)

### Features

* Add tag for Managed Node Groups to private subnet.

## [0.1.29]() (2024-12-30)

### Features

* Add private database subnet group

## [0.1.22]() (2024-12-25)

### Features

* Separate the VPC and Security Group
* Introduced a conditional mechanism to control the creation of VPC flow logs.

## [0.1.14]() (2024-12-18)

### Features

* Add variables: `create_custom_subnets`, `custom_public_subnets`, `custom_private_subnets` and update subnet creation
  logics.
* Correct `aws_security_group.allow_all_within_vpc` ingress rule `cidr_blocks`.
* Remove `environment` from resource tags.

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code
