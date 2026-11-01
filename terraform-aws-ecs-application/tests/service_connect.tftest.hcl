mock_provider "aws" {
  mock_resource "aws_ecs_service" {
    defaults = {
      id = "arn:aws:ecs:us-west-2:111122223333:service/default/servicetest"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::111122223333:role/permissions-boundary-test"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::111122223333:policy/permissions-boundary-test"
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

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/servicetest-tg/1111111111111111"
    }
  }

  mock_data "aws_vpc" {
    defaults = {
      cidr_block = "10.0.0.0/16"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_ssm_parameter" {
    defaults = {
      value = "{\"image_id\":\"ami-0123456789abcdef0\"}"
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
  use_alb                   = true
  alb_dns_name              = "shared-alb.example.invalid"
  alb_security_groups       = ["sg-0123456789abcdef0"]
  aws_lb_listener_arn       = "arn:aws:elasticloadbalancing:us-west-2:111122223333:listener/app/shared/2222222222222222/3333333333333333"
  alb_zone_id               = "Z1H1FL5HABSF5"
  dns_name                  = "servicetest.example.invalid"
  route53_zone_id           = "Z0000000000000000000"
}

run "disabled_by_default" {
  command = plan

  assert {
    condition     = length(aws_ecs_service.this.service_connect_configuration) == 0
    error_message = "Service Connect configuration must be omitted when disabled by default."
  }
}

run "enabled_with_namespace" {
  command = plan

  variables {
    enabled_service_connect = true
    service_connect_configuration = {
      namespace = "arn:aws:servicediscovery:us-west-2:111122223333:namespace/ns-0123456789abcdef0"
    }
  }

  assert {
    condition     = length(aws_ecs_service.this.service_connect_configuration) == 1
    error_message = "Enabling Service Connect must create exactly one configuration block."
  }

  assert {
    condition     = aws_ecs_service.this.service_connect_configuration[0].enabled == true
    error_message = "The Service Connect configuration must be enabled."
  }
}
