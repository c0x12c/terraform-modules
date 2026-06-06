/*
aws_cloudwatch_log_group provides a CloudWatch Log Group resource for awslogs driver.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
*/
resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${local.cloudwatch_log_group_name}"

  tags = {
    Name        = local.cloudwatch_log_group_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "migration" {
  count = var.cloudwatch_log_group_migration_name != null ? 1 : 0

  name = "/ecs/${var.cloudwatch_log_group_migration_name}"

  tags = {
    Name        = var.cloudwatch_log_group_migration_name
    Environment = var.environment
  }
}

/*
aws_ecs_service provides an ECS service - effectively a task that is expected to run until an error occurs or a user terminates it (typically a webserver or a database).
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
*/
resource "aws_ecs_service" "this" {
  name                               = var.name
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = var.service_desired_count
  enable_execute_command             = var.enable_execute_command
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  launch_type                        = var.launch_type
  scheduling_strategy                = local.is_fargate ? "REPLICA" : var.scheduling_strategy
  force_new_deployment               = var.force_new_deployment

  network_configuration {
    security_groups  = compact(concat([try(aws_security_group.this[0].id, null)], var.security_group_ids))
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
  }

  deployment_circuit_breaker {
    enable   = var.enable_deployment_circuit_breaker
    rollback = var.deployment_circuit_breaker_rollback
  }

  dynamic "load_balancer" {
    for_each = var.use_alb ? [1] : []

    content {
      container_name   = "${var.name}-container"
      container_port   = var.container_port
      target_group_arn = try(aws_lb_target_group.this[0].arn, null)
    }
  }

  service_connect_configuration {
    enabled   = var.enabled_service_connect
    namespace = var.service_connect_configuration.namespace

    dynamic "service" {
      for_each = var.service_connect_configuration.service != null ? [1] : []

      content {
        discovery_name = var.service_connect_configuration.service.discovery_name
        port_name      = var.service_connect_configuration.service.port_name

        client_alias {
          dns_name = var.service_connect_configuration.service.client_alias.dns_name
          port     = var.service_connect_configuration.service.client_alias.port
        }
      }
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_service_arn != null ? [1] : []

    content {
      registry_arn = var.service_discovery_service_arn
    }
  }

  # desired_count is ignored as it can change due to autoscaling policy
  lifecycle {
    ignore_changes = [desired_count]
  }
}

/*
aws_ecs_task_definition manages a revision of an ECS task definition to be used in aws_ecs_service.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
*/
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = [var.launch_type]
  /**
   * 256 (.25 vCPU) - 512 MB, 1 GB, 2 GB
   * 512 (.5 vCPU) - 1 GB, 2 GB, 3 GB, 4 GB
   * 1024 (1 vCPU) - 2 GB, 3 GB, 4 GB, 5 GB, 6 GB, 7 GB, 8 GB
   * 2048 (2 vCPU) - Between 4 GB and 16 GB in 1 GB increments
   * 4096 (4 vCPU) - Between 8 GB and 30 GB in 1 GB increments
   * 8192 (8 vCPU) - Between 16 GB and 60 GB in 4 GB increments
   * 16384 (16vCPU) - Between 32 GB and 120 GB in 8 GB increments
   */
  cpu                   = var.task_cpu
  memory                = var.task_memory
  execution_role_arn    = aws_iam_role.task_execution_role.arn
  task_role_arn         = aws_iam_role.task_role.arn
  container_definitions = jsonencode(local.container_definitions)

  dynamic "volume" {
    for_each = var.persistent_volume != null ? [var.name] : []
    content {
      name = volume.value
      efs_volume_configuration {
        file_system_id = module.efs[0].file_system_id

        transit_encryption      = "ENABLED"
        transit_encryption_port = 2999

        authorization_config {
          access_point_id = module.efs[0].access_points[volume.value].id
          iam             = "ENABLED"
        }
      }
    }
  }

  tags = {
    Name        = "${var.name}-task"
    Environment = var.environment
  }
}

/*
aws_appautoscaling_target provides an Application AutoScaling ScalableTarget resource.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target
*/
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.service_max_capacity
  min_capacity       = var.service_desired_count
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

/*
aws_appautoscaling_policy provides an Application AutoScaling Policy resource.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy
*/
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
}


resource "aws_launch_template" "this" {
  count = var.launch_type == "EC2" ? 1 : 0

  image_id               = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type          = var.ec2_configuration.instance_type
  vpc_security_group_ids = var.security_group_ids
  user_data              = var.ec2_configuration.user_data

  iam_instance_profile {
    name = aws_iam_instance_profile.this[0].name
  }
}


resource "aws_autoscaling_group" "this" {
  count = var.launch_type == "EC2" ? 1 : 0

  name = "${var.name}-autoscaling-group-ecs-${var.environment}"

  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = []
  health_check_type         = "EC2"
  health_check_grace_period = 300

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.this[0].id
    version = aws_launch_template.this[0].latest_version
  }
}