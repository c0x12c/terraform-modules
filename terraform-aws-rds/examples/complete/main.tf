# Terraform owns the password. Rotate it by changing db_password_rotation_id; drive that
# from a time_rotating resource if you want it on an interval rather than by hand.
module "postgresql" {
  source = "../../"

  db_name                             = "example_rds"
  db_username                         = "exampleuser"
  engine_version                      = "18.4"
  instance_class                      = "db.t4g.micro"
  disk_size                           = 20
  storage_type                        = "gp3"
  iam_database_authentication_enabled = false
  replica_count                       = 0
  vpc_id                              = "vpc-123456789"
  subnet_ids                          = []
  cloudwatch_exported_log_types       = ["postgresql", "upgrade"]

  db_password_rotation_id = "2026-08"
}

# AWS owns the password and rotates it natively, every 30 days instead of its 7-day default.
# expose_managed_master_password resolves the value back into the db_password output; leave
# it off and use db_password_secret_arn instead.
module "rds_managed_password" {
  source = "../../"

  db_name        = "example_rds_managed"
  db_username    = "exampleuser"
  engine_version = "18.4"
  instance_class = "db.t4g.micro"
  disk_size      = 20
  storage_type   = "gp3"
  replica_count  = 0
  vpc_id         = "vpc-123456789"
  subnet_ids     = []

  manage_master_user_password      = true
  expose_managed_master_password   = true
  master_user_secret_rotation_days = 30
}

# Same, but pinned to a window instead of an interval - 06:00 UTC on the 1st of the month,
# finishing within two hours. Use this when the credential change has to miss a traffic peak
# or a batch job. The schedule and days forms are mutually exclusive.
module "rds_managed_password_windowed" {
  source = "../../"

  db_name        = "example_rds_windowed"
  db_username    = "exampleuser"
  engine_version = "18.4"
  instance_class = "db.t4g.micro"
  disk_size      = 20
  storage_type   = "gp3"
  replica_count  = 0
  vpc_id         = "vpc-123456789"
  subnet_ids     = []

  manage_master_user_password          = true
  master_user_secret_rotation_schedule = "cron(0 6 1 * ? *)"
  master_user_secret_rotation_duration = "2h"
}
