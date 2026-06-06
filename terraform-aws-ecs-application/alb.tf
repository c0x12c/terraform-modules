resource "aws_lb_target_group" "this" {
  count = var.use_alb ? 1 : 0

  name        = "${var.name}-tg"
  port        = var.container_port
  protocol    = var.container_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    enabled             = var.target_group_configuration.health_check_enabled != null ? var.target_group_configuration.health_check_enabled : var.health_check_enabled
    healthy_threshold   = var.target_group_configuration.health_check_healthy_threshold
    interval            = var.target_group_configuration.health_check_interval
    protocol            = var.target_group_configuration.health_check_protocol
    port                = var.target_group_configuration.health_check_port
    matcher             = var.target_group_configuration.health_check_matcher != null ? var.target_group_configuration.health_check_matcher : var.health_check_path
    timeout             = var.target_group_configuration.health_check_timeout
    path                = var.target_group_configuration.health_check_path
    unhealthy_threshold = var.target_group_configuration.health_check_unhealthy_threshold
  }
}

resource "aws_lb_listener_rule" "this" {
  count = var.use_alb ? 1 : 0

  listener_arn = var.aws_lb_listener_arn
  priority     = var.aws_lb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    host_header {
      values = [aws_route53_record.this[0].fqdn]
    }
  }
}
