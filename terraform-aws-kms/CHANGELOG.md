# Changelog

All notable changes to this project will be documented in this file.

## [0.3.15]() (2025-04-11)

### Features

* Add statements to KMS policy via `additional_statements`.

## [0.1.17]() (2024-12-23)

### Fix bugs

* Update policy statement

## [0.1.16]() (2024-12-20)

### Fix bugs

* Add policy `kms:PutKeyPolicy` to fix bugs

## [0.1.15]() (2024-12-19)

### Fix bugs

* Change from `aws_iam_policy.this[*].arn` to `values(aws_iam_policy.this)[*].arn` in order to fix the null list output

## [0.1.12]() (2024-12-17)

### Features

* Update README.md
* Change name -> alias_name and make it into a `list(string)`
* Update examples, outputs and description of some variables.
* Update policy

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.2]() (2024-12-04)

### Features

* Initial commit with all the code

