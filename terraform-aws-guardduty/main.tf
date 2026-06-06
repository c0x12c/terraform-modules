/*
https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/guardduty_detector
This resource enables Amazon GuardDuty, a threat detection service that continuously monitors malicious activity and unauthorized behavior.
*/
resource "aws_guardduty_detector" "this" {
  enable = var.enabled_guardduty

  datasources {
    s3_logs {
      enable = var.enabled_guardduty_s3_scanning
    }
    kubernetes {
      audit_logs {
        enable = var.enabled_guardduty_eks_audit
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enabled_guardduty_ebs_malware_detection
        }
      }
    }
  }
}

/*
https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/sns_topic
This resource creates an Amazon SNS topic, which is used to send notifications about GuardDuty findings.
*/
resource "aws_sns_topic" "this" {
  count = var.enabled_email_notification && var.enabled_guardduty ? 1 : 0

  name = "${var.name}-guardduty-findings-to-emails"
}

/*
https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/sns_topic_subscription
This resource sets up an email subscription to the Amazon SNS topic, so specified email addresses can receive notifications about GuardDuty findings.
*/
resource "aws_sns_topic_subscription" "this" {
  for_each = toset(var.notifications_received_email_list)

  topic_arn = aws_sns_topic.this[0].arn
  protocol  = "email"
  endpoint  = each.value
}

/*
https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/cloudwatch_event_rule
This resource defines an Amazon CloudWatch Event rule to capture GuardDuty finding events.
*/
resource "aws_cloudwatch_event_rule" "this" {
  count = var.enabled_email_notification && var.enabled_guardduty ? 1 : 0

  name          = "${var.name}-guardduty-finding-events"
  description   = "AWS GuardDuty event findings"
  event_pattern = file("${path.module}/event-pattern.json")
}

/*
https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/cloudwatch_event_target
This resource connects the CloudWatch Event rule to the SNS topic, ensuring that GuardDuty findings trigger email notifications.
It also transforms the event data into a readable format using an input transformer.
*/
resource "aws_cloudwatch_event_target" "this" {
  count = var.enabled_email_notification && var.enabled_guardduty ? 1 : 0

  rule      = aws_cloudwatch_event_rule.this[0].name
  target_id = "${var.name}-guardduty-to-email"
  arn       = aws_sns_topic.this[0].arn

  input_transformer {
    input_paths = {
      Account_ID          = "$.detail.accountId"
      severity            = "$.detail.severity"
      Finding_description = "$.detail.description"
      region              = "$.region"
      Finding_Type        = "$.detail.type"
      Finding_ID          = "$.detail.id"
    }

    input_template = file("${path.module}/input-template.txt")
  }
}
