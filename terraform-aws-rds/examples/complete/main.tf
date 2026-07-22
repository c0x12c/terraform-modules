module "postgresql" {
  source = "../../"

  db_name                             = "example_rds"
  db_username                         = "exampleuser"
  instance_class                      = "db.t3.micro"
  disk_size                           = 10
  iam_database_authentication_enabled = false
  replica_count                       = 0
  vpc_id                              = "vpc-123456789"
  subnet_ids                          = []
  storage_type                        = "gp2"
  cloudwatch_exported_log_types       = ["postgresql", "upgrade"]
}

module "rds_managed_password" {
  source = "../../"

  db_name                     = "example_rds_managed"
  db_username                 = "exampleuser"
  instance_class              = "db.t3.micro"
  disk_size                   = 10
  manage_master_user_password = true
  replica_count               = 0
  vpc_id                      = "vpc-123456789"
  subnet_ids                  = []
  storage_type                = "gp2"
}
