# Representative AWS examples, with account/region/service aligned to these inputs:
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_service_deployment_events.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_service_events.html
mock_provider "aws" {
  mock_resource "aws_ecs_service" {
    defaults = {
      id = "arn:aws:ecs:us-west-2:111122223333:service/default/servicetest"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::111122223333:role/notification-test"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::111122223333:policy/notification-test"
    }
  }

  mock_resource "aws_lambda_function" {
    defaults = {
      arn = "arn:aws:lambda:us-west-2:111122223333:function/notification-test"
    }
  }

  mock_resource "aws_cloudwatch_event_rule" {
    defaults = {
      arn = "arn:aws:events:us-west-2:111122223333:rule/notification-test"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

mock_provider "archive" {}

variables {
  name                      = "servicetest"
  region                    = "us-west-2"
  ecs_cluster_id            = "arn:aws:ecs:us-west-2:111122223333:cluster/default"
  ecs_cluster_name          = "default"
  vpc_id                    = "vpc-12345678"
  task_memory               = 2048
  task_cpu                  = 1024
  container_port            = 8080
  container_image           = "example.invalid/test:latest"
  ecs_execution_policy_arns = []
  use_alb                   = false
  alb_dns_name              = ""
  alb_security_groups       = []
  aws_lb_listener_arn       = ""
  alb_zone_id               = ""
  dns_name                  = ""
  route53_zone_id           = ""
  enabled_notification      = true
  slack_webhook_url         = "https://example.invalid/test"
}

run "documented_events_match_production_patterns" {
  command = apply

  assert {
    # AWS deployment examples omit clusterArn. Every required detail key must
    # exist and match; adding an unsupported required field fails this assertion.
    condition = contains(keys(local.notification_event_rules[0].event_pattern.detail), "eventName") && alltrue([
      for key, values in local.notification_event_rules[0].event_pattern.detail :
      contains(values, lookup({
        eventType    = "ERROR"
        eventName    = "SERVICE_DEPLOYMENT_FAILED"
        deploymentId = "ecs-svc/123"
        updatedAt    = "2020-05-23T11:11:11Z"
        reason       = "ECS deployment circuit breaker: task failed to start."
      }, key, ""))
    ])
    error_message = "Deployment failure events must match without detail.clusterArn."
  }

  assert {
    condition = contains(keys(local.notification_event_rules[1].event_pattern.detail), "eventName") && alltrue([
      for key, values in local.notification_event_rules[1].event_pattern.detail :
      contains(values, lookup({
        eventType  = "ERROR"
        eventName  = "SERVICE_TASK_PLACEMENT_FAILURE"
        clusterArn = "arn:aws:ecs:us-west-2:111122223333:cluster/default"
        reason     = "RESOURCE:FARGATE"
      }, key, ""))
    ])
    error_message = "Service action names must match eventName, not severity eventType."
  }

  assert {
    condition = alltrue([
      for rule in slice(local.notification_event_rules, 0, 2) :
      rule.event_pattern.source[0] == "aws.ecs" &&
      startswith("arn:aws:ecs:us-west-2:111122223333:service/default/servicetest", rule.event_pattern.resources[0].prefix) &&
      !startswith("arn:aws:ecs:us-west-2:111122223333:service/default/other-service", rule.event_pattern.resources[0].prefix)
    ]) && local.notification_event_rules[0].event_pattern.detail-type[0] == "ECS Deployment State Change" && local.notification_event_rules[1].event_pattern.detail-type[0] == "ECS Service Action"
    error_message = "Event source/type and service ARN scope must remain intact."
  }
}
