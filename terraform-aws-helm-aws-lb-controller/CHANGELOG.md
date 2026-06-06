# Changelog

All notable changes to this project will be documented in this file.

## [1.2.1]() (2025-11-15)

### Bug Fixes

* Fix YAML parse error by escaping dots in serviceAccount annotation key for `eks.amazonaws.com/role-arn`.

## [1.2.0]() (2025-10-12)

### ⚠ BREAKING CHANGES

* Update Helm provider version constraint to v3.

## [1.1.0]() (2025-06-25)

### ⚠ Features

* Add `additional_load_balancer_attributes` for customize the access logging and others load balancer attributes to internal LB.

## [1.0.1]() (2025-06-24)

### ⚠ Features

* Add `additional_load_balancer_attributes` for customize the access logging and others load balancer attributes

## [1.0.0]() (2025-06-17)

### BREAKING CHANGES

* Changed module name to `helm-aws-lb-controller` and flatten it to aws root folder for Terraform Registry discovery compatibility.

## [0.3.11]() (2025-04-09)

# Features

* Add the external default service to handle the custom ingress controller

## [0.3.7]() (2025-03-30)

# Features

* Update policies and add require permission to those

## [0.3.0]() (2025-03-30)

# Features

* Add the labels and tolerations

## [0.1.75]() (2025-03-06)

# Features

* Add the wafv2 arn acl config for load balancer.

## [0.1.53]() (2025-01-13)

# Features

* Add region as optional, use the data source `aws_region` to get the region if it is null.

## [0.1.42]() (2025-01-09)

# Features

* Add new policy documents for chart versions and auto get policy version based on chart_version.

## [0.1.20]() (2024-12-24)

### Features

* Initial commit with all the code
