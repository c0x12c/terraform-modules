/**
Provides an SNS topic resource.
https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/sns_topic
 */
resource "aws_sns_topic" "this" {
  name = var.name
}

/**
Provides a resource for subscribing to SNS topics.
https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/sns_topic_subscription
 */
resource "aws_sns_topic_subscription" "this" {
  for_each = { for sub in var.subscriptions : sub.name => sub }

  protocol  = each.value["protocol"]
  endpoint  = each.value["endpoint"]
  topic_arn = aws_sns_topic.this.arn
}
