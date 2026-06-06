# Changelog

All notable changes to this project will be documented in this file.
## [0.5.3]() (2025-05-13)

### Features
* Add `nodejs_configuration` to customize nodejs version in case projects need the latest version nodejs.

### Changes
* Update credential plugins version, which is the reason that cause crash for jenkins

## [0.1.67]() (2025-02-19)

### Changes
* Create the credential using github_app_credential_id instead of gihub_credential_id
* Remove unused input `gihub_credential_id`

## [0.1.59]() (2025-01-20)

### Features

* Updated README files to include usage details for installing and configuring EKS Helm modules

## [0.1.36]() (2024-01-02)

### Features

* Remove variable validation with ref to other var since this feature hasn't been supported in OpenTofu

## [0.1.35]() (2024-01-02)

### Features

* Update the Jenkins `gitHubPluginConfig` to match the variable `github_org_display_name`.

## [0.1.34]() (2024-01-02)

### Features

* Add variable `jenkins_config_map_name` to use configMapRef in containerEnvFrom
* Add variable `jenkins_viewer` to add permission for GitHub team groups that defined in jenkins viewer

## [0.1.31]() (2024-12-30)

### Features

* Init module with all the code

