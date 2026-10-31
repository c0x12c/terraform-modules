mock_provider "aws" {}
mock_provider "archive" {}

variables {
  name               = "notifier"
  environment        = "dev"
  slack_webhook_url  = "https://hooks.slack.com/services/T/B/X"
  lambda_source_file = "./README.md"
  event_rules = [
    { name = "a2345678901234567890123456789012345678901234567890", description = "13 prefix + 50 = 63", event_pattern = { source = ["aws.ecs"] } },
    { name = "b23456789012345678901234567890123456789012345678901", description = "13 prefix + 51 = 64", event_pattern = { source = ["aws.ecs"] } },
    { name = "c234567890123456789012345678901234567890123456789012", description = "13 prefix + 52 = 65", event_pattern = { source = ["aws.ecs"] } },
  ]
}

run "target_id_is_unchanged_up_to_the_limit_and_truncated_over_it" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_target.this["a2345678901234567890123456789012345678901234567890"].target_id == "SendToLambda-a2345678901234567890123456789012345678901234567890"
    error_message = "A 63-character target_id must stay unchanged."
  }

  assert {
    condition     = aws_cloudwatch_event_target.this["b23456789012345678901234567890123456789012345678901"].target_id == "SendToLambda-b23456789012345678901234567890123456789012345678901"
    error_message = "A 64-character target_id must stay unchanged."
  }

  assert {
    condition     = aws_cloudwatch_event_target.this["c234567890123456789012345678901234567890123456789012"].target_id == "SendToLambda-c23456789012345678901234567890123456789012345678901"
    error_message = "A 65-character target_id must be cut to 64."
  }
}
