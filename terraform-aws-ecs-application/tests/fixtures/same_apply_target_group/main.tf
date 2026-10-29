# The target group is created in the same plan, so its ARN is unknown when the module plans.
resource "aws_lb_target_group" "external" {
  name        = "external"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-12345678"
}

module "app" {
  source = "../../.."

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
  alb_dns_name              = ""
  alb_security_groups       = ["sg-0123456789abcdef0"]
  aws_lb_listener_arn       = ""
  alb_zone_id               = ""
  dns_name                  = ""
  route53_zone_id           = ""
  external_target_group     = { arn = aws_lb_target_group.external.arn }
}
