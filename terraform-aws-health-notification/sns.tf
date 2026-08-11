resource "aws_sns_topic" "this" {
  count = var.create_sns_topic ? 1 : 0

  name              = local.sns_topic_name
  kms_master_key_id = var.sns_kms_master_key_id

  tags = merge(var.tags, {
    Name = local.sns_topic_name
  })
}

resource "aws_sns_topic_policy" "this" {
  count = var.create_sns_topic || var.manage_existing_topic_policy ? 1 : 0

  arn = local.sns_topic_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${local.sns_topic_name}-policy"
    Statement = [
      {
        Sid    = "AllowEventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = local.sns_topic_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.this.arn
          }
        }
      },
      {
        Sid    = "AllowCloudWatchPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = local.sns_topic_arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "this" {
  for_each = var.subscriptions

  topic_arn            = local.sns_topic_arn
  protocol             = each.value.protocol
  endpoint             = each.value.endpoint
  raw_message_delivery = each.value.raw_message_delivery
  filter_policy        = each.value.filter_policy
  filter_policy_scope  = each.value.filter_policy_scope
}
