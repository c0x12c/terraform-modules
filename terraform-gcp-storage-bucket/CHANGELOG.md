# Changelog

All notable changes to this project will be documented in this file.

## [0.6.5]() (2025-06-03)

### Features

* Add `lifecycle_rules` and `soft_delete_policy`.
* Add `logging` to define destination bucket for storing access logs.
* Add `enable_creator_policy` to add permission for log bucket to create log objects.

## [0.6.0]() (2025-05-26)

### ⚠ BREAKING CHANGES

* Separate permissions of Google Cloud Storage bucket and objects: Add `is_listable` variable to manage bucket
  permission, allow `allUsers` to list object. `is_public` variable allow `allUsers` to get object as usual.

## [0.1.5]() (2024-12-06)

### Features

* Initial commit with all the code
