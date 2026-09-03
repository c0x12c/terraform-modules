# Aurora PostgreSQL with IAM database authentication.
#
# The module builds the `rds-db:connect` policy for the roles named in `iam_auth_db_roles` and
# exports its ARN. Attaching that policy to a workload's role is left to the caller, because the
# role usually lives outside this module - an EKS pod identity, an ECS task role, a Lambda role.

module "cluster" {
  source = "../../"

  name            = "example-iam-auth"
  engine          = "aurora-postgresql"
  engine_version  = "17.9"
  database_name   = "exampledb"
  master_username = "exampleuser"

  vpc_id  = "vpc-123456789"
  subnets = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

  instance_class = "db.r6g.large"
  instances = {
    main = { availability_zone = "us-west-2a" }
  }

  db_cluster_parameter_group_family = "aurora-postgresql17"

  security_group_rules = {
    eks = { source_security_group_id = "sg-eks-workers" }
  }

  # Each entry becomes one dbuser ARN in the policy. These are DATABASE role names, not IAM
  # principals - they must already exist in Postgres and hold `rds_iam` membership, which is
  # what makes the DB accept a token instead of a password.
  #
  # The master user cannot be one of them. RDS refuses to grant `rds_iam` to a role that also has
  # password authentication, so a migrator that needs both a password path and IAM auth has to be
  # a separate role.
  iam_auth_db_roles = ["app", "migrator"]
}

# The module does not attach the policy - it only builds it. Attach it to whichever principal
# connects to the database.
resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = module.cluster.iam_auth_policy_arn
}

resource "aws_iam_role" "app" {
  name = "example-iam-auth-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}
