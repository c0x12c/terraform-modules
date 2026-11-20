mock_provider "aws" {
  mock_data "aws_vpc" {
    defaults = {
      cidr_block = "10.0.0.0/16"
    }
  }

  mock_resource "aws_security_group" {
    defaults = {
      id = "sg-0123456789abcdef0"
    }
  }
}

mock_provider "random" {}

variables {
  db_name       = "ingresstest"
  db_username   = "testuser"
  vpc_id        = "vpc-12345678"
  subnet_ids    = ["subnet-12345678", "subnet-87654321"]
  replica_count = 0
}

run "default_vpc_ingress" {
  command = plan

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.this) == 1 && length(aws_vpc_security_group_ingress_rule.allowed_security_group) == 0
    error_message = "Default ingress must keep exactly one CIDR rule and no security group rules."
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.this[0].cidr_ipv4 == "10.0.0.0/16" && aws_vpc_security_group_ingress_rule.this[0].from_port == var.port && aws_vpc_security_group_ingress_rule.this[0].to_port == var.port && aws_vpc_security_group_ingress_rule.this[0].ip_protocol == "tcp"
    error_message = "Default ingress must allow the VPC CIDR on the database TCP port."
  }
}

run "restricted_security_group_ingress" {
  command = plan

  variables {
    allowed_security_group_ids = ["sg-11111111111111111", "sg-22222222222222222"]
    port                       = 3306
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.this) == 0 && length(aws_vpc_security_group_ingress_rule.allowed_security_group) == 2
    error_message = "Restricted ingress must replace the CIDR rule with two security group rules."
  }

  assert {
    condition = alltrue([
      for index, rule in aws_vpc_security_group_ingress_rule.allowed_security_group :
      rule.referenced_security_group_id == var.allowed_security_group_ids[index] && rule.from_port == 3306 && rule.to_port == 3306 && rule.ip_protocol == "tcp" && rule.cidr_ipv4 == null
    ])
    error_message = "Each rule must reference its listed security group and allow only the configured TCP port."
  }
}

run "security_group_output" {
  command = apply

  assert {
    condition     = output.security_group_id == "sg-0123456789abcdef0" && output.security_group_id == aws_security_group.this.id
    error_message = "security_group_id must expose the database security group ID."
  }
}
