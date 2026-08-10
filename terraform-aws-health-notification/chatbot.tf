resource "aws_chatbot_slack_channel_configuration" "this" {
  for_each = var.slack_channels

  configuration_name = coalesce(each.value.configuration_name, "${var.name}-${each.key}-slack")
  iam_role_arn       = coalesce(each.value.iam_role_arn, local.chatbot_role)
  slack_team_id      = each.value.workspace_id
  slack_channel_id   = each.value.channel_id

  sns_topic_arns = [local.sns_topic_arn]

  # Left unset so the API keeps its AdministratorAccess default; an empty list would drift.
  guardrail_policy_arns       = length(each.value.guardrail_policy_arns) > 0 ? each.value.guardrail_policy_arns : null
  logging_level               = each.value.logging_level
  user_authorization_required = each.value.user_authorization_required

  tags = merge(var.tags, {
    Name = coalesce(each.value.configuration_name, "${var.name}-${each.key}-slack")
  })

  lifecycle {
    precondition {
      condition     = each.value.iam_role_arn != null || local.chatbot_role != null
      error_message = "Slack channel \"${each.key}\" has no IAM role: set create_iam_role, iam_role_arn, or the channel's own iam_role_arn."
    }
  }
}
