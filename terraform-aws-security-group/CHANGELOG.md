# Changelog

All notable changes to this project will be documented in this file.

## [0.1.58]() (2025-01-15)

### Features

* Add variable to custom ipv6_cidr_blocks of the default security group `allow_all_within_vpc`.

## [0.1.33]() (2025-01-02)

### Features

* Updated the logic to set from_port and to_port to -1 when the IP protocol is "-1", ensuring compatibility for security
  group rules with all protocols.

## [0.1.30]() (2024-12-30)

### Features

* Update Security Group Resources to Support Dynamic Ingress and Egress Rule Management

## [0.1.29]() (2024-12-29)

### Features

* Add variable `tags` to custom security groups avoid update security group during migration
*

## [0.1.27]() (2024-12-26)

### Features

* Add variable `custom_sg_allow_all_within_vpc_egress_ipv6_cidr_blocks` to avoid update sg during migration

## [0.1.25]() (2024-12-26)

### Features

* Add variables: `custom_sg_allow_all_description` and `custom_sg_allow_all_within_all_description` to avoid forces
  replacement during migration.

## [0.1.23]() (2024-12-26)

### Features

* Introduced functionality to create default security groups with configurable CIDR blocks and VPC ID

## [0.1.22]() (2024-12-25)

### Features

* Initialize Security Groups modules
