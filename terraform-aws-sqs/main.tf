locals {
  suffix          = var.fifo_enabled ? ".fifo" : ""
  dlq_queue_name  = "${var.name}-dlq${local.suffix}"
  queue_name      = "${var.name}${local.suffix}"
  aws_account_id  = data.aws_caller_identity.current.account_id
  aws_region      = data.aws_region.current.name
  queue_resources = concat([aws_sqs_queue.queue.arn], (var.enabled_dead_letter_queue == true ? [aws_sqs_queue.dlq[0].arn] : []))

  principal_roles = var.principal_roles != null ? var.principal_roles : [
    "arn:aws:iam::${local.aws_account_id}:root"
  ]

  redrive_policy = <<POLICY
{
  "deadLetterTargetArn":"${try(aws_sqs_queue.dlq[0].arn, "")}",
  "maxReceiveCount": ${var.max_receive_count}
}
POLICY
}

/*
aws_sqs_queue dlq creates a dead-letter queue (DLQ) for handling messages that can't be processed successfully.
Configured with default SQS settings and optional FIFO settings based on input variables.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
*/
resource "aws_sqs_queue" "dlq" {
  count                     = var.enabled_dead_letter_queue ? 1 : 0
  name                      = local.dlq_queue_name
  delay_seconds             = "0"
  max_message_size          = var.max_size
  message_retention_seconds = var.dlq_retention_seconds
  receive_wait_time_seconds = "0"

  fifo_queue = var.fifo_enabled

  kms_master_key_id                 = var.enabled_kms_encryption ? var.kms_config.kms_master_key_id : null
  kms_data_key_reuse_period_seconds = var.enabled_kms_encryption ? var.kms_config.kms_data_key_reuse_period_seconds : null

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.queue.arn]
  })
}

/*
aws_sqs_queue queue creates the main SQS queue with configuration for visibility, delay, retention, and optional FIFO.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
*/
resource "aws_sqs_queue" "queue" {
  name                       = local.queue_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_size
  message_retention_seconds  = var.retention_seconds
  receive_wait_time_seconds  = var.wait_seconds

  fifo_queue                  = var.fifo_enabled
  deduplication_scope         = var.fifo_deduplication_scope
  fifo_throughput_limit       = var.fifo_throughput_limit
  content_based_deduplication = var.content_based_deduplication

  kms_master_key_id                 = var.enabled_kms_encryption ? var.kms_config.kms_master_key_id : null
  kms_data_key_reuse_period_seconds = var.enabled_kms_encryption ? var.kms_config.kms_data_key_reuse_period_seconds : null
}

/*
aws_iam_policy_document creates an IAM policy document allowing specified roles (or any if unspecified)
to access the main SQS queue. This can restrict access to specific AWS principals.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
*/
data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.principal_roles
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.queue.arn]
  }
}

/*
aws_sqs_queue_policy attaches the IAM policy document to the main SQS queue.
This policy controls access to the queue based on the specified IAM roles or all users.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy
*/
resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.this.json
}


resource "aws_sqs_queue_redrive_policy" "this" {
  count = var.enabled_dead_letter_queue ? 1 : 0

  queue_url = aws_sqs_queue.queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  })
}

data "aws_iam_policy_document" "sqs_dlq" {
  count = var.enabled_dead_letter_queue ? 1 : 0

  version = "2012-10-17"
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.principal_roles
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.dlq[0].arn]
  }
}

resource "aws_sqs_queue_policy" "dlq" {
  count     = var.enabled_dead_letter_queue && var.enabled_dlq_queue_policy ? 1 : 0
  queue_url = aws_sqs_queue.dlq[0].url
  policy    = data.aws_iam_policy_document.sqs_dlq[0].json
}
