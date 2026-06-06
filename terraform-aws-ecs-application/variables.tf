# general
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The AWS region in which resources are created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets to associate with the task or service"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security groups to associate with the task or service"
  type        = list(string)
  default     = []
}

# ecs
variable "name" {
  description = "The name ECS application"
  type        = string
}

variable "task_memory" {
  description = "Task memory."
  type        = number
}

variable "task_cpu" {
  description = "Task cpu."
  type        = number
}

variable "container_port" {
  description = "Port of container to be exposed"
  type        = number
}

variable "container_protocol" {
  description = "Protocol of container to be exposed"
  type        = string
  default     = "HTTP"
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
  type        = number
  default     = 0
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
  type        = number
  default     = 2048
}

variable "container_image" {
  description = "Docker image to be launched"
  type        = string
}

variable "container_secrets" {
  description = "The container secret environment variables"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "container_environment" {
  description = "The container environment variables"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "service_desired_count" {
  description = "Number of services running in parallel"
  type        = number
  default     = 2
}

variable "service_max_capacity" {
  description = "Maximum of services running in parallel"
  type        = number
  default     = 2
}

variable "ecs_execution_policy_arns" {
  description = "Permission to make AWS API calls"
  type        = list(string)
}

variable "ecs_cluster_id" {
  description = "ID of the ECS cluster for this ECS application"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster for this ECS application"
  type        = string
}

variable "health_check_enabled" {
  description = "Specify whether enabling health check for this ECS service or not"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Default path for health check requests"
  type        = string
  default     = "/health"
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service"
  type        = bool
  default     = true
}

variable "additional_iam_policy_arns" {
  description = "Additional policies for ECS task role"
  type        = list(string)
  default     = []
}

variable "additional_container_definitions" {
  description = "Custom container definition"
  type        = list(any)
  default     = []
}

variable "additional_port_mappings" {
  description = "Additional port mappings to service container."
  type = list(object({
    protocol      = string
    containerPort = number
    hostPort      = number
    name          = optional(string, null)
  }))
  default = []
}

variable "enabled_port_mapping" {
  description = "Whether to use TCP port mapping to service container."
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "Enable to assign the public ip to the tasks"
  type        = bool
  default     = false
}

variable "persistent_volume" {
  description = "Directory path for the EFS volume"
  type = object({
    path = string,
    gid  = optional(number, 1000)
    uid  = optional(number, 1000)
  })
  default = null
}

variable "user" {
  description = "User to run the container"
  type        = string
  default     = null
}

variable "use_alb" {
  description = "Whether to use alb for this ecs task."
  type        = bool
  default     = true
}

variable "container_command" {
  description = "Container command."
  type        = list(string)
  default     = []
}

variable "container_entryPoint" {
  description = "Container entrypoint"
  type        = list(string)
  default     = []
}

variable "awslogs_stream_prefix" {
  description = "AWS logs stream prefix."
  type        = string
  default     = "ecs"
}

variable "container_depends_on" {
  type = list(object({
    containerName = string
    condition     = string
  }))
  default = []
}

# alb & r53
variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_security_groups" {
  description = "List of security group IDs of the ALB"
  type        = list(string)
}

variable "aws_lb_listener_arn" {
  description = "ARN of the ALB"
  type        = string
}

variable "aws_lb_listener_rule_priority" {
  description = "AWS LB listener rule's priority"
  type        = number
  default     = 100
}

variable "alb_zone_id" {
  description = "Hosted zone id of the ALB"
  type        = string
}

variable "dns_name" {
  description = "DNS name for the ECS application"
  type        = string
}

variable "route53_zone_id" {
  description = "R53 zone ID"
  type        = string
}

# cloudwatch
variable "cloudwatch_log_group_name" {
  description = "Overwrite existing aws_cloudwatch_log_group name."
  type        = string
  default     = null
}

## flyway log
variable "cloudwatch_log_group_migration_name" {
  description = "Overwrite existing aws_cloudwatch_log_group migration name."
  type        = string
  default     = null
}

# iam
variable "overwrite_task_execution_role_name" {
  description = "Overwrite ECS task execution role name."
  type        = string
  default     = null
}

variable "overwrite_task_role_name" {
  description = "Overwrite ECS task role name."
  type        = string
  default     = null
}

variable "task_policy_secrets_description" {
  description = "The description of IAM policy for task secrets."
  type        = string
  default     = "Policy that allows access to the ssm we created"
}

variable "task_policy_ssm_description" {
  description = "The description of IAM policy for task ssm."
  type        = string
  default     = "Policy that allows access to the ssm we created"
}

# datadog
variable "enabled_datadog_sidecar" {
  description = "Whether to use Datadog sidecar for monitoring and logging."
  type        = bool
  default     = false
}

variable "dd_site" {
  type    = string
  default = null
}

variable "dd_api_key_arn" {
  type    = string
  default = null
}

variable "dd_agent_image" {
  description = "Datadog agent image."
  type        = string
  default     = "public.ecr.aws/datadog/agent:latest"
}

variable "dd_port" {
  description = "Datadog agent port."
  type        = number
  default     = 8126
}

variable "dd_sidecar_environment" {
  description = "Additional environment variables for the Datadog sidecar container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# service connect
variable "port_mapping_name" {
  description = "Container port mapping name for service connect."
  type        = string
  default     = "main"
}

variable "enabled_service_connect" {
  description = "Whether to create service connect namespace for service internal discovery."
  type        = bool
  default     = false
}

variable "service_connect_configuration" {
  description = "Service connect configuration within namespace."
  type = object({
    namespace = string
    service = optional(object({
      discovery_name = string
      port_name      = string
      client_alias = object({
        dns_name = string
        port     = number
      })
    }), null)
  })
  default = {
    namespace = null
    service   = null
  }
}

variable "service_discovery_service_arn" {
  description = "Service discovery service arn."
  type        = string
  default     = null
}

variable "enable_execute_command" {
  description = "Whether to enable execute command for the ECS task."
  type        = bool
  default     = false
}

variable "launch_type" {
  description = "Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `FARGATE`"
  type        = string
  default     = "FARGATE"
  nullable    = false
}

variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service. The valid values are `REPLICA` and `DAEMON`. Defaults to `REPLICA`"
  type        = string
  default     = "REPLICA"
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's `desired_count`) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = 50
}

variable "deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's `desired_count`) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = 200
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers"
  type        = number
  default     = 60
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling for the ECS service."
  type        = bool
  default     = true
}

variable "create_iam_instance_profile" {
  description = "Whether to create an IAM instance profile for the ECS service."
  type        = bool
  default     = false
}

variable "ec2_configuration" {
  description = "EC2 configuration."
  type = object({
    instance_type        = string
    user_data            = string
    privileged           = bool
    shared_memory_size   = number
    init_process_enabled = bool
  })
  default = {
    instance_type        = "t3.medium"
    user_data            = null
    privileged           = false
    shared_memory_size   = null
    init_process_enabled = null
  }
}

# notification
variable "enabled_notification" {
  description = "Whether to enable ECS service and task event notifications."
  type        = bool
  default     = false
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for sending notifications."
  type        = string
  default     = null
  sensitive   = true
}

variable "notification_deployment_event_types" {
  description = "List of ECS deployments event types"
  type        = list(string)
  default = [
    "SERVICE_DEPLOYMENT_IN_PROGRESS",
    "SERVICE_DEPLOYMENT_COMPLETED",
    "SERVICE_DEPLOYMENT_FAILED"
  ]
}

variable "notification_service_event_types" {
  description = "List of ECS service event types to trigger notifications. Empty by default as deployments are tracked separately. Can include: SERVICE_TASK_PLACEMENT_FAILURE, SERVICE_STEADY_STATE"
  type        = list(string)
  default     = ["SERVICE_TASK_PLACEMENT_FAILURE", "SERVICE_STEADY_STATE"]
}

variable "notification_task_stop_codes" {
  description = "List of ECS task stop codes to trigger notifications for STOPPED tasks. Filters for critical failures only."
  type        = list(string)
  default     = ["TaskFailedToStart", "EssentialContainerExited", "ContainerFailedToStart"]
}

variable "enable_deployment_circuit_breaker" {
  description = "Whether to enable the deployment circuit breaker logic for the service. If enabled, a service deployment will transition to a failed state and stop launching new tasks if it can't reach a steady state."
  type        = bool
  default     = true
}

variable "deployment_circuit_breaker_rollback" {
  description = "Whether to enable automatic rollback when the circuit breaker triggers. Only takes effect if enable_deployment_circuit_breaker is true."
  type        = bool
  default     = false
}

variable "target_group_configuration" {
  description = "Target group configuration."
  type = object({
    health_check_enabled             = optional(bool, true)
    health_check_path                = optional(string, "/health")
    health_check_protocol            = optional(string, "HTTP")
    health_check_port                = optional(number, 8080)
    health_check_interval            = optional(number, 120)
    health_check_timeout             = optional(number, 60)
    health_check_healthy_threshold   = optional(number, 2)
    health_check_unhealthy_threshold = optional(number, 7)
    health_check_matcher             = optional(string, "200")
  })
  default = {
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
}