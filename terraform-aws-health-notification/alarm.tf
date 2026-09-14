################################################################################
# Delivery failure alarm
################################################################################

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
  ok_actions          = [local.sns_topic_arn]

  dimensions = {
    TopicName = local.sns_topic_name
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
