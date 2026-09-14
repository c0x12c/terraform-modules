################################################################################
# Heartbeat - daily proof of SNS delivery
################################################################################

# EventBridge Scheduler always assumes an execution role to deliver, so the role
# here is inherent to Scheduler rather than a workaround.
#
# It grants sns:Publish through the role's IDENTITY policy rather than the topic
# policy. The topic policy's EventBridge statement allows publish only when
# aws:SourceArn equals this module's own rule ARN, so anything else - a second
# rule, or Scheduler - fails that condition and is denied.

data "aws_iam_policy_document" "scheduler_assume" {
  count = var.enable_heartbeat ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    # Without these any Scheduler principal in any account could assume the role and
    # publish to the topic - the confused-deputy shape. The ARN is built from name,
    # region and account rather than read off aws_scheduler_schedule.heartbeat, which
    # would be a cycle since the schedule references this role.
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.heartbeat_schedule_arn]
    }
  }
}

data "aws_iam_policy_document" "scheduler_publish" {
  count = var.enable_heartbeat ? 1 : 0

  statement {
    sid    = "AllowSchedulerPublishToHealthTopic"
    effect = "Allow"

    actions = ["sns:Publish"]
    resources = [
      local.sns_topic_arn,
    ]
  }

  # Publishing to a topic encrypted with a customer-managed key needs KMS permission as well, or
  # every scheduled publish fails while the schedule itself reports as created. The key may be
  # given as an id or an alias rather than an ARN, so this cannot name a key resource; the
  # kms:ViaService condition confines it to KMS calls SNS makes in this Region instead.
  dynamic "statement" {
    for_each = var.sns_kms_master_key_id == null ? [] : [1]

    content {
      sid    = "AllowSchedulerUseOfTopicKey"
      effect = "Allow"

      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey*",
      ]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["sns.${data.aws_region.current.name}.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "scheduler" {
  count = var.enable_heartbeat ? 1 : 0

  name               = local.heartbeat_name
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume[0].json

  tags = merge(var.tags, {
    Name = local.heartbeat_name
  })

  # IAM role names and Scheduler schedule names both cap at 64 characters, and the suffix added
  # here spends up to 32 of them. Fail at plan with the arithmetic rather than at apply with an
  # AWS validation error, and only when the heartbeat is actually switched on - var.name itself
  # stays unconstrained for every consumer that does not use it.
  lifecycle {
    precondition {
      condition     = length(local.heartbeat_name) <= 64
      error_message = "name is too long for the heartbeat: \"${local.heartbeat_name}\" is ${length(local.heartbeat_name)} characters and IAM roles and EventBridge Scheduler schedules both cap at 64. Shorten var.name by ${length(local.heartbeat_name) - 64} characters or leave enable_heartbeat false."
    }
  }
}

resource "aws_iam_role_policy" "scheduler_publish" {
  count = var.enable_heartbeat ? 1 : 0

  name   = local.heartbeat_name
  role   = aws_iam_role.scheduler[0].id
  policy = data.aws_iam_policy_document.scheduler_publish[0].json
}

locals {
  heartbeat_description_computed = coalesce(var.heartbeat_description, "${var.name} health delivery heartbeat")

  # IAM role names are account-global, so two instances of this module in different Regions with
  # the same var.name would collide on the role. The Region is part of the name to keep them apart.
  heartbeat_name = "${var.name}-health-heartbeat-${data.aws_region.current.name}"

  # Schedules land in the "default" group because group_name is not set below.
  heartbeat_schedule_arn = "arn:${data.aws_partition.current.partition}:scheduler:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:schedule/default/${local.heartbeat_name}"
}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "aws_scheduler_schedule" "heartbeat" {
  count = var.enable_heartbeat ? 1 : 0

  name                         = local.heartbeat_name
  description                  = "Daily heartbeat that proves the SNS delivery path works after external drift."
  schedule_expression          = var.heartbeat_schedule_expression
  schedule_expression_timezone = "UTC"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = local.sns_topic_arn
    role_arn = aws_iam_role.scheduler[0].arn
    input = jsonencode({
      version = "1.0"
      source  = "custom"
      content = {
        description = local.heartbeat_description_computed
      }
    })
  }

  depends_on = [aws_iam_role_policy.scheduler_publish[0]]
}
