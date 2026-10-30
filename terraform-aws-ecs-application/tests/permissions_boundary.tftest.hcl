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

run "unset_boundary" {
  command = plan

  assert {
    condition     = aws_iam_role.task_role.permissions_boundary == null && aws_iam_role.task_execution_role.permissions_boundary == null
    error_message = "Task and execution roles must have no permissions boundary by default."
  }
}

run "set_boundary" {
  command = plan

  variables {
    iam_role_permissions_boundary = "arn:aws:iam::111122223333:policy/test-boundary"
  }

  assert {
    condition     = aws_iam_role.task_role.permissions_boundary == "arn:aws:iam::111122223333:policy/test-boundary" && aws_iam_role.task_execution_role.permissions_boundary == "arn:aws:iam::111122223333:policy/test-boundary"
    error_message = "Task and execution roles must use the supplied permissions boundary."
  }
}

run "ec2_instance_role_boundary" {
  command = plan

  variables {
    launch_type                   = "EC2"
    create_iam_instance_profile   = true
    iam_role_permissions_boundary = "arn:aws:iam::111122223333:policy/test-boundary"
    ec2_configuration = {
      instance_type        = "t3.medium"
      user_data            = null
      privileged           = false
      shared_memory_size   = 64
      init_process_enabled = true
    }
  }

  assert {
    condition     = aws_iam_role.this[0].permissions_boundary == "arn:aws:iam::111122223333:policy/test-boundary"
    error_message = "The EC2 instance profile role must use the supplied permissions boundary."
  }
}
