mock_provider "aws" {
  mock_resource "aws_ecs_service" {
    defaults = {
      id = "arn:aws:ecs:us-west-2:111122223333:service/default/servicetest"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::111122223333:role/external-tg-test"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::111122223333:policy/external-tg-test"
    }
  }

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/servicetest-tg/1111111111111111"
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
  use_alb                   = true
  alb_dns_name              = "shared-alb.example.invalid"
  alb_security_groups       = ["sg-0123456789abcdef0"]
  aws_lb_listener_arn       = "arn:aws:elasticloadbalancing:us-west-2:111122223333:listener/app/shared/2222222222222222/3333333333333333"
  alb_zone_id               = "Z1H1FL5HABSF5"
  dns_name                  = "servicetest.example.invalid"
  route53_zone_id           = "Z0000000000000000000"
}

run "default_module_owned_routing_creates_record" {
  command = plan

  assert {
    condition     = length(aws_route53_record.this) == 1
    error_message = "With module-owned routing and create_dns_record unset, exactly one Route53 record must be created."
  }
}

run "external_target_group_without_opt_in_creates_no_record" {
  command = plan

  variables {
    external_target_group = { arn = "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/ext/0123456789abcdef" }
  }

  assert {
    condition     = length(aws_route53_record.this) == 0
    error_message = "An external target group without create_dns_record must create no Route53 record."
  }
}

run "external_target_group_with_opt_in_creates_record" {
  command = plan

  variables {
    external_target_group = { arn = "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/ext/0123456789abcdef" }
    create_dns_record     = true
  }

  assert {
    condition     = length(aws_route53_record.this) == 1
    error_message = "create_dns_record = true must create the Route53 record even with an external target group."
  }

  assert {
    condition     = aws_route53_record.this[0].name == "servicetest.example.invalid" && aws_route53_record.this[0].zone_id == "Z0000000000000000000"
    error_message = "The record must use dns_name and route53_zone_id."
  }

  assert {
    condition     = one(aws_route53_record.this[0].alias).name == "shared-alb.example.invalid" && one(aws_route53_record.this[0].alias).zone_id == "Z1H1FL5HABSF5"
    error_message = "The alias must point at alb_dns_name and alb_zone_id."
  }

  assert {
    condition     = length(aws_lb_listener_rule.this) == 0
    error_message = "Opting into the record must not create a listener rule."
  }
}

run "owned_routing_without_record_keeps_listener_rule" {
  command = plan

  variables {
    create_dns_record = false
  }

  assert {
    condition     = length(aws_route53_record.this) == 0 && length(aws_lb_listener_rule.this) == 1
    error_message = "create_dns_record = false must skip the record and keep the listener rule, hosted on dns_name."
  }
}

run "dns_record_requires_zone_id" {
  command = plan

  variables {
    external_target_group = { arn = "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/ext/0123456789abcdef" }
    create_dns_record     = true
    route53_zone_id       = null
  }

  expect_failures = [var.create_dns_record]
}
