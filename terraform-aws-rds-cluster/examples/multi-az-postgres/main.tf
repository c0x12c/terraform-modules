module "cluster" {
  source = "../../"

  name            = "example-multi-az-pg"
  engine          = "postgres"
  engine_version  = "18.3"
  database_name   = "exampledb"
  master_username = "exampleuser"

  vpc_id  = "vpc-123456789"
  subnets = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

  # Multi-AZ DB cluster requires these. gp3 with custom IOPS requires
  # allocated_storage >= 400 GB and iops >= 12000 on postgres.
  db_cluster_instance_class = "db.r6gd.large"
  allocated_storage         = 400
  iops                      = 12000
  storage_type              = "gp3"

  db_cluster_parameter_group_family = "postgres18"

  # No instances map — Multi-AZ DB cluster manages its 3 instances internally
  instances = {}

  monitoring_interval                   = 60
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  deletion_protection = false
  skip_final_snapshot = true
}
