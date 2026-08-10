resource "random_password" "this" {
  count = !var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  # keepers is ForceNew, so ANY change to it replaces the password - including going back to
  # null after a value has been used. There is no "stop rotating" transition: once opted in,
  # clearing the handle is itself a rotation. Null by default, otherwise adopting this module
  # version would rotate every existing database at once.
  keepers = var.db_password_rotation_id == null ? null : {
    rotation = var.db_password_rotation_id
  }

  length  = var.password_length
  special = false
}

data "aws_secretsmanager_random_password" "this" {
  count = var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  password_length     = var.password_length
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret" "this" {
  count = var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  name = var.secret_manager_db_password_name
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.use_secret_manager && !var.manage_master_user_password ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = data.aws_secretsmanager_random_password.this[0].id

  // ignore any updates to the initial values above done after creation.
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}

data "aws_secretsmanager_secret_version" "managed" {
  count = local.read_managed_secret ? 1 : 0

  secret_id = local.managed_secret_arn
}

resource "aws_secretsmanager_secret_rotation" "managed" {
  # Errors when manage_master_user_password is enabled in Terraform without the out-of-band
  # step first, since the ARN is then known-null. The README rules that path out.
  count = local.manage_master_secret_rotation ? 1 : 0

  secret_id = local.managed_secret_arn

  # The provider defaults this to true, so omitting it rotates every managed master password
  # on the run that adopts these inputs. Rotate out of band if you want one immediately.
  rotate_immediately = false

  rotation_rules {
    automatically_after_days = var.master_user_secret_rotation_days
    schedule_expression      = var.master_user_secret_rotation_schedule
    duration                 = var.master_user_secret_rotation_duration
  }

  # No rotation_lambda_arn: an RDS-owned secret (OwningService: rds) is rotated by RDS itself.
}

# Rotation failing is silent. The secret stops rotating, nothing fails at the time, and the
# first symptom is an authentication error long afterwards with nothing pointing back here.
resource "aws_cloudwatch_event_rule" "master_secret_rotation_failed" {
  count = local.notify_master_secret_rotation_failure ? 1 : 0

  name        = "${local.identifier}-master-secret-rotation-failed"
  description = "Rotation of the RDS-managed master secret for ${local.identifier} failed or was abandoned"

  # Field names verified against real CloudTrail events from an RDS-owned secret: rotation
  # events arrive as AwsServiceEvent (not an API call) and carry the secret ARN in
  # additionalEventData.SecretId. Without that filter every RDS in the account matches.
  #
  # RotationAbandoned is included because it also leaves the secret un-rotated.
  event_pattern = jsonencode({
    source        = ["aws.secretsmanager"]
    "detail-type" = ["AWS Service Event via CloudTrail"]
    detail = {
      eventSource         = ["secretsmanager.amazonaws.com"]
      eventName           = ["RotationFailed", "RotationAbandoned"]
      additionalEventData = { SecretId = [local.managed_secret_arn] }
    }
  })
}

resource "aws_cloudwatch_event_target" "master_secret_rotation_failed" {
  count = local.notify_master_secret_rotation_failure ? 1 : 0

  rule = aws_cloudwatch_event_rule.master_secret_rotation_failed[0].name
  arn  = var.master_user_secret_rotation_failure_sns_topic_arn

  # The topic's own resource policy must allow events.amazonaws.com to publish. That lives
  # with the topic, not here, so a topic without it drops these notifications silently.
}
