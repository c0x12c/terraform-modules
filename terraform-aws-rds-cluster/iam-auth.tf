data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "iam_auth_connect" {
  count = length(var.iam_auth_db_roles) > 0 ? 1 : 0

  name = "${var.name}-rds-iam-connect"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "rds-db:connect"
        # An Aurora cluster has one resource ID covering every instance, so every IAM login role
        # can use the same cluster-scoped ARN. A single-instance RDS database has a distinct ID.
        Resource = [
          for role in var.iam_auth_db_roles :
          "arn:aws:rds-db:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.this.cluster_resource_id}/${role}"
        ]
      }
    ]
  })
}
