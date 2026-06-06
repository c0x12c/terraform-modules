module "eventbridge-slack-notification" {
  count = var.enabled_notification ? 1 : 0

  source  = "c0x12c/eventbridge-slack-notification/aws"
  version = "~> 1.1.0"

  name              = var.name
  environment       = var.environment
  slack_webhook_url = var.slack_webhook_url

  lambda_source_file = "${path.module}/files/index.mjs"
  lambda_handler     = "index.handler"
  lambda_runtime     = "nodejs22.x"

  additional_iam_policy_arns = {
    lambda_ecs_policy = aws_iam_policy.lambda_ecs_policy[0].arn
  }

  lambda_environment_variables = {
    ENVIRONMENT  = var.environment
    CLUSTER_NAME = var.ecs_cluster_name
    SERVICE_NAME = var.name
  }

  event_rules = [
    {
      name        = "${var.name}-ecs-deployment-events"
      description = "ECS Deployment State Changes"
      event_pattern = {
        source      = ["aws.ecs"]
        detail-type = ["ECS Deployment State Change"]
        resources = [
          {
            prefix = aws_ecs_service.this.id
          }
        ]
        detail = {
          eventName  = var.notification_deployment_event_types
          clusterArn = [var.ecs_cluster_id]
        }
      }
    },
    {
      name        = "${var.name}-ecs-service-events"
      description = "ECS Service State Changes"
      event_pattern = {
        source      = ["aws.ecs"]
        detail-type = ["ECS Service Action"]
        resources = [
          {
            prefix = aws_ecs_service.this.id
          }
        ]
        detail = {
          eventType  = var.notification_service_event_types
          clusterArn = [var.ecs_cluster_id]
        }
      }
    },
    {
      name        = "${var.name}-ecs-task-events"
      description = "ECS Task State Changes"
      event_pattern = {
        source      = ["aws.ecs"]
        detail-type = ["ECS Task State Change"]
        resources = [
          {
            prefix = "${replace(var.ecs_cluster_id, ":cluster/", ":task/")}/"
          }
        ]
        detail = {
          lastStatus = ["STOPPED"]
          stopCode   = var.notification_task_stop_codes
          clusterArn = [var.ecs_cluster_id]
          group      = ["service:${var.name}"]
        }
      }
    }
  ]

  depends_on = [aws_iam_policy.lambda_ecs_policy]
}
