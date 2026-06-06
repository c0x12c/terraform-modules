# Changelog

All notable changes to this project will be documented in this file.

## [2.2.0]() (2026-03-01)

### Features

* Update Lambda runtime from `nodejs20.x` to `nodejs22.x`

## [2.1.0]() (2026-02-25)

### Features

* Add Dependabot auto-merge GitHub Actions workflow:
  * Automatically merges Dependabot PRs for GitHub Actions updates (all semver types).
  * Automatically merges Dependabot PRs for Terraform patch updates.

### Bug Fixes

* Fix Datadog sidecar container dependency ordering:
  * Add explicit dependency on Datadog container to ensure it starts before the main application container.

## [2.0.1]() (2025-12-29)

### Fix Bugs
* Fix the condition for `health_check_matcher` and `health_check_enabled` for deprecation condition.


## [2.0.0]() (2025-12-29)

### BREAKING CHANGES 

* Introduces new variable `target_group_configuration`, to customize the target group health check and protocol. In some cases, we don't have any health check path for tasks or disable the TLS for container because those are public images. We have to customize our health check for support those cases such as `health_check_matcher = 200-404` to make sure that our pods alive but don't have any health check path, or adjust protocol to `HTTPS`.
  default: 
  ```
  target_group_configuration = {
    health_check_enabled             = true
    health_check_path                = "/health"
    health_check_protocol            = "HTTP"
    health_check_port                = 8080
    health_check_interval            = 120
    health_check_timeout             = 60
    health_check_healthy_threshold   = 2
    health_check_unhealthy_threshold = 7
    health_check_matcher             = "200"
  }
  ```
* Although we add that new environment, but still keep the default one as the old version, with the same configuration.
* DEPRECATED `health_check_enabled` and `health_check_path`, when we use the target_group_configuration, those will override those two variables. Those variables will keep for some version due to supportting backward compatible.

## [1.3.0]() (2025-11-03)

### Features

* Add deployment circuit breaker support:
  * Introduces new variable `enable_deployment_circuit_breaker` (default: `true`) to enable automatic detection of failed deployments.
  * Introduces new variable `deployment_circuit_breaker_rollback` (default: `false`) to enable automatic rollback when circuit breaker triggers.

## [1.2.7]() (2025-10-25)

### Bug Fixes

* Fix Datadog sidecar environment variable type error:
  * Change boolean values to strings in Datadog container environment variables to fix error: `ECS Task Definition container_definitions is invalid: json: cannot unmarshal bool into Go struct field KeyValuePair.Environment.Value of type string`.
  * All environment variable values must be strings as per ECS task definition requirements.

## [1.2.6]() (2025-10-25)

### Features

* Add support for custom Datadog sidecar environment variables:
  * Introduces new variable `dd_sidecar_environment` to pass additional environment variables to the Datadog sidecar container.
  * Allows customization of Datadog agent configuration while preserving default settings.

## [1.2.5]() (2025-10-18)

### Bug Fixes

* Fix ECS task event filtering field name in EventBridge rule:
  * Correct event pattern field from `groupName` to `group` for task state change events.
  * This aligns with the correct AWS EventBridge event structure for ECS task events.

## [1.2.4]() (2025-10-16)

* Use consistent prefix-based resource filtering for all EventBridge event patterns:
  * Convert deployment and service event rules to use `prefix` format for resources field.
  * Add resource prefix filtering for task state change events using cluster-based task ARN pattern.

## [1.2.3]() (2025-10-16)

### Bug Fixes

* Improve EventBridge deployment event filtering:
  * Add `resources` filter with ECS service ID to deployment state change event pattern.

## [1.2.2]() (2025-10-15)

### Bug Fixes

* Fix ECS task event filtering in EventBridge rule:
  * Replace `serviceName` with `groupName` pattern `service:${var.name}` to correctly match ECS task events.
  * This fixes the notification filtering for STOPPED tasks which use `groupName` instead of `serviceName` in their event structure.

## [1.2.1]() (2025-10-14)

### Features

* Add ECS event notification support via EventBridge and Slack integration:
  * Introduces new variables:
    * `enabled_notification`: to enable/disable ECS event notifications.
    * `slack_webhook_url`: webhook URL for Slack notifications.
    * `notification_deployment_event_types`: list of deployment event types to monitor.
    * `notification_service_event_types`: list of service event types to monitor.
    * `notification_task_stop_codes`: list of ECS task stop codes to trigger notifications for STOPPED tasks.
  * Lambda function for processing ECS events and sending formatted Slack notifications with rich formatting (color-coded severity, AWS Console links, container exit information).
  * Conditional module creation - notification infrastructure only created when `enabled_notification = true`.
  * EventBridge rules for monitoring deployment, service, and task events.

## [1.2.0]() (2025-10-01)

### Features

* Introduces new variables:
  * `launch_type`: to define launch type `FARGATE` or `EC2`.
  * `scheduling_strategy`, `deployment_minimum_healthy_percent`, `deployment_maximum_percent` and `health_check_grace_period_seconds` to customize those attributes instead of using hardcode value.
  * `enable_autoscaling` to enable autoscaling for ECS which was set default to true, however in `EC2` mode, this one are not required.
  * `ec2_configuration` for customize `EC2` relating fields.

## [1.1.0]() (2025-08-19)

### Added

* Add service discovery support.

## [1.0.0]() (2025-07-15)

### BREAKING CHANGES

* Move module to `c0x12c` GitHub Org and deploy module to Terraform Registry.
* Update module source and dependency in README.

## [0.2.5]() (2025-03-18)

### Features

* Allow all connection within VPC to container port if `enabled_service_connect` set to `true`.

## [0.2.4]() (2025-03-18)

### Bug Fixes

* Add object attribute `name` to variable `additional_port_mappings`.

## [0.2.3]() (2025-03-18)

### Features

* Add variable `port_mapping_name` for service connect.

## [0.2.2]() (2025-03-18)

### Features

* Add ECS Service Connect using `enabled_service_connect` and `service_connect_configuration`.

## [0.2.1]() (2025-03-18)

### Features

* Introduces new variables:
    * `task_cpu` and `task_memory`: to define task resources, container resource defined
      by `container_cpu`, `container_memory`.
    * `cloudwatch_log_group_name`, `cloudwatch_log_group_migration_name`: to define cloudwatch log group name.
      If `cloudwatch_log_group_migration_name` is not null, it will create a log group for service migration logs.
    * `overwrite_task_role_name`, `overwrite_task_execution_role_name`, `task_policy_secrets_description`, `task_policy_ssm_description`:
      fallback on default value.
    * `enabled_datadog_sidecar`, `dd_site`, `dd_api_key_arn`, `dd_agent_image`, `dd_port`: supports datadog sidecar
      definitions.
    * `use_alb`: whether to use ALB.
    * `enabled_port_mapping`: whether to use TCP port mapping to service container.

## [0.1.78]() (2025-03-10)

### Features

* Add `persistent_volume` and integrate with EFS service

## [0.1.67]() (2025-02-17)

### Features

* Add flag `assign_public_ip`

## [0.1.63]() (2025-01-24)

### Features

* Refactor module, remove datadog configuration

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code
