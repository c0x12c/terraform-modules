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

run "default_alb_caller_unchanged" {
  command = plan

  assert {
    condition     = length(aws_lb_target_group.this) == 1 && length(aws_lb_listener_rule.this) == 1 && length(aws_route53_record.this) == 1
    error_message = "A caller that does not set external_target_group_arn must keep the module-owned target group, listener rule and Route53 record."
  }

  assert {
    condition     = length(aws_ecs_service.this.load_balancer) == 1
    error_message = "The service must keep exactly one load_balancer block."
  }
}

run "external_target_group_skips_routing" {
  command = plan

  variables {
    external_target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/ext/0123456789abcdef"
  }

  assert {
    condition     = length(aws_lb_target_group.this) == 0 && length(aws_lb_listener_rule.this) == 0 && length(aws_route53_record.this) == 0
    error_message = "An external target group must replace the module-owned target group, listener rule and Route53 record."
  }

  assert {
    condition     = one(aws_ecs_service.this.load_balancer).target_group_arn == "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/ext/0123456789abcdef"
    error_message = "The service must attach to the external target group."
  }

  assert {
    condition     = length(aws_security_group.this) == 1
    error_message = "The service security group must still admit the ALB security groups."
  }

  assert {
    condition     = output.alb_target_group_arn == "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/ext/0123456789abcdef"
    error_message = "alb_target_group_arn must report the external target group."
  }
}

run "no_alb_caller_unchanged" {
  command = plan

  variables {
    use_alb = false
  }

  assert {
    condition     = length(aws_lb_target_group.this) == 0 && length(aws_lb_listener_rule.this) == 0 && length(aws_route53_record.this) == 0
    error_message = "use_alb = false must create no ALB routing."
  }

  assert {
    condition     = length(aws_ecs_service.this.load_balancer) == 0 && length(aws_security_group.this) == 0
    error_message = "use_alb = false must create no load_balancer block and no service security group."
  }
}

run "external_requires_use_alb" {
  command = plan

  variables {
    use_alb                   = false
    external_target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:111122223333:targetgroup/ext/0123456789abcdef"
  }

  expect_failures = [var.external_target_group_arn]
}

run "external_rejects_non_target_group_arn" {
  command = plan

  variables {
    external_target_group_arn = "arn:aws:iam::111122223333:role/x"
  }

  expect_failures = [var.external_target_group_arn]
}
