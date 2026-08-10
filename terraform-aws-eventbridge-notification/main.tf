locals {
  eventbridge_rule_name = coalesce(var.eventbridge_rule_name, "${var.name}-notification")
  sns_topic_name        = coalesce(var.sns_topic_name, "${var.name}-notification")

  default_event_pattern = jsonencode({
    source        = ["aws.health"]
    "detail-type" = ["AWS Health Event"]
  })

  event_pattern  = coalesce(var.event_pattern, local.default_event_pattern)
  sns_topic_arn  = var.create_sns_topic ? aws_sns_topic.this[0].arn : var.sns_topic_arn
  chatbot_count  = length(var.slack_channels) + length(var.teams_channels)
  create_chatbot = var.create_iam_role && local.chatbot_count > 0
  chatbot_role   = local.create_chatbot ? aws_iam_role.chatbot[0].arn : var.iam_role_arn
}

resource "aws_cloudwatch_event_rule" "this" {
  name           = local.eventbridge_rule_name
  description    = var.eventbridge_rule_description
  event_bus_name = var.event_bus_name
  event_pattern  = local.event_pattern

  tags = merge(var.tags, {
    Name = local.eventbridge_rule_name
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule           = aws_cloudwatch_event_rule.this.name
  event_bus_name = var.event_bus_name
  target_id      = "SendToSNS"
  arn            = local.sns_topic_arn

  dynamic "input_transformer" {
    for_each = var.input_transformer == null ? [] : [var.input_transformer]

    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }
}
