data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

/*
aws_iam_role.this creates the IAM role for the AWS Scheduler.
The role is used to execute actions defined in the scheduler target.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
*/
resource "aws_iam_role" "this" {
  name               = "${var.name}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name = "${var.name}-scheduler-role"
  }
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    sid    = "AllowSQSSendMessage"
    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [var.sqs_arn]
  }
}

/*
aws_iam_policy.this creates the IAM policy that attaches the permissions for SQS actions to the role.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
*/
resource "aws_iam_policy" "this" {
  name   = "${var.name}-scheduler-policy"
  policy = data.aws_iam_policy_document.sqs_policy.json

  tags = {
    Name = "${var.name}-scheduler-policy"
  }
}
