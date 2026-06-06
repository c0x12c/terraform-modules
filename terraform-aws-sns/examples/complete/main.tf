module "sns" {
  source = "../../"

  name = "sns-topic"
  subscriptions = [
    {
      name     = "sqs-email-received-local"
      protocol = "sqs"
      endpoint = "queue-arn"
    }
  ]
}
