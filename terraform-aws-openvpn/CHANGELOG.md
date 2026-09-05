# Changelog

All notable changes to this project will be documented in this file.
## [0.6.2](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-openvpn/v0.6.1...terraform-aws-openvpn/v0.6.2) (2026-09-05)


### Bug Fixes

* **terraform-aws-openvpn:** keep each pushed option on its own line ([#327](https://github.com/c0x12c/terraform-modules/issues/327)) ([baff30c](https://github.com/c0x12c/terraform-modules/commit/baff30cc2851c875f8475da53e9757fa01ce4332))

## [0.6.1](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-openvpn/v0.6.0...terraform-aws-openvpn/v0.6.1) (2026-08-24)


### Bug Fixes

* **terraform-aws-openvpn:** stop clients asking for a client certificate ([#295](https://github.com/c0x12c/terraform-modules/issues/295)) ([74f0e41](https://github.com/c0x12c/terraform-modules/commit/74f0e41885d96e36fa22a76a594365cc409d80d6))

## [0.6.0]() (2026-04-29)
Add variables `dns_server_cidrs` for OpenVPN, so it could able to resolve some DNS inside VPC while using VPC Peering.

## [0.5.0]() (2025-04-21)

### Feature

* Add variable `enabled_http_port` to make HTTP optional from security group.

## [0.1.62]() (2025-01-24)

### Feature

* Make ssh rule in security group optional and disable by default, var: `allow_remote_ssh_access`

### Bug fixes

* Correct instance id and instance arn output

## [0.1.51]() (2025-01-12)

### Feature

* Add optional existing public key value `ec2_public_key` and custom key name `key_name`.
* Add security group to allow ssh access to vpn `default_ssh_vpn`.
* Remove resource tag.

## [0.1.33]() (2025-01-02)

### Feature

* Add outputs for EC2 instance.
* Introduced `http_tokens` and `http_endpoint` variables to control instance metadata service settings.

## [0.1.31]() (2024-12-30)

### Fix

* Fix missing a new line in the init script cause server not configure properly.

## [0.1.30]() (2024-12-30)

### Fix

* Add a flag to determine whenever to recreate OpenVPN instance when there is update in some variables:
  `replace_instance_on_update`.

## [0.1.28]() (2024-12-26)

### Features

* Allow using this module to use various available OAuth2 provider by adding variables: `oauth2_provider`,
  `oauth2_issuer`
* Allow validate group and role of the authorized identity via `oauth2_validate_groups` and `oauth2_validate_roles`
* Make management ssh key optional `create_management_key_pair`
* And add some variables for migrations: `custom_cert_dns_names`, `create_egress_vpn_rule`,
  `init_script_callback_comment`

## [0.1.13]() (2024-12-17)

### Features

* Init and update OpenVPN module
