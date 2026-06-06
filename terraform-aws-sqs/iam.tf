data "aws_iam_policy_document" "read" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = local.queue_resources
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ListQueues"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "write" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]
    resources = local.queue_resources
  }
}

data "aws_iam_policy_document" "read_write" {
  count = var.enabled_read_write_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:SendMessage",
    ]
    resources = local.queue_resources
  }
}

resource "aws_iam_policy" "read" {
  name        = var.read_policy_name != null ? var.read_policy_name : "SQSRead-${var.name}"
  description = "Policy that allows receive message from a shared queue."
  policy      = data.aws_iam_policy_document.read.json
}

resource "aws_iam_policy" "write" {
  name        = var.write_policy_name != null ? var.write_policy_name : "SQSWrite-${var.name}"
  description = "Policy that allows send message from a shared queue."
  policy      = data.aws_iam_policy_document.write.json
}

resource "aws_iam_policy" "read_write" {
  count       = var.enabled_read_write_policy ? 1 : 0
  name        = var.read_write_policy_name != null ? var.read_write_policy_name : "SQSReadWrite-${var.name}"
  description = "Policy that allows send and receive message from a shared queue."
  policy      = data.aws_iam_policy_document.read_write[0].json
}
