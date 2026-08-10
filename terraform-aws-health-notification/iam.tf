data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "chatbot_assume_role" {
  count = local.create_chatbot ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "chatbot" {
  count = local.create_chatbot ? 1 : 0

  name               = coalesce(var.iam_role_name, "${var.name}-chatbot-role")
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume_role[0].json

  tags = merge(var.tags, {
    Name = coalesce(var.iam_role_name, "${var.name}-chatbot-role")
  })
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  for_each = local.create_chatbot ? toset(var.iam_policy_arns) : toset([])

  role       = aws_iam_role.chatbot[0].name
  policy_arn = each.value
}
