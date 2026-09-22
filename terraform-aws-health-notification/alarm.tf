################################################################################
# Delivery failure alarm
################################################################################

locals {
  # local.sns_topic_name is the name this module would GIVE a topic it creates. When an existing
  # topic is supplied instead, its real name is the last segment of the ARN - using the computed
  # name there would point the alarm at a metric that does not exist, and it would sit green
  # forever.
  alarm_topic_name = var.create_sns_topic ? local.sns_topic_name : element(split(":", local.sns_topic_arn), 5)
}

resource "aws_cloudwatch_metric_alarm" "delivery_failures" {
  count = var.enable_delivery_alarm ? 1 : 0

  alarm_name          = "${var.name}-health-notification-failures"
  alarm_description   = "Alarm when the health notification SNS topic records failed deliveries."
  namespace           = "AWS/SNS"
  metric_name         = "NumberOfNotificationsFailed"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = var.delivery_alarm_ok_actions ? [local.sns_topic_arn] : []

  dimensions = {
    TopicName = local.alarm_topic_name
  }

  # This alarm notifies through the very topic it watches, so it can only report
  # PARTIAL delivery failure - some subscriptions failing while others still work.
  # Total delivery failure cannot announce itself here; the signal for that case is
  # the heartbeat going missing. The two checks cover different halves, which is why
  # enabling only one leaves a gap.

  tags = merge(var.tags, {
    Name = "${var.name}-health-notification-failures"
  })
}
