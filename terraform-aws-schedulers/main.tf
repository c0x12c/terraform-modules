/*
aws_scheduler_schedule creates a schedule using EventBridge Scheduler.
The schedule triggers a target action (e.g., sending SQS messages) based on a specified cron expression.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule
*/
resource "aws_scheduler_schedule" "this" {
  name = "${var.name}-scheduler"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:sqs:sendMessage"
    role_arn = aws_iam_role.this.arn

    input = jsonencode({
      MessageBody = var.message_body
      QueueUrl    = var.queue_url
    })
  }
}
