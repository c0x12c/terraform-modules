module "cluster" {
  source = "../../"

  name            = "example-aurora-pg"
  engine          = "aurora-postgresql"
  engine_version  = "17.9"
  database_name   = "exampledb"
  master_username = "exampleuser"

  vpc_id  = "vpc-123456789"
  subnets = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

  instance_class = "db.r6g.large"
  instances = {
    main    = { availability_zone = "us-west-2a" }
    replica = { availability_zone = "us-west-2b" }
  }

  db_cluster_parameter_group_family = "aurora-postgresql17"
  db_cluster_parameter_group_parameters = [
    { name = "rds.logical_replication", value = "1", apply_method = "pending-reboot" },
  ]

  security_group_rules = {
    eks = { source_security_group_id = "sg-eks-workers" }
  }

  monitoring_interval                   = 60
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  enabled_cloudwatch_logs_exports = ["postgresql"]
  deletion_protection             = false
  skip_final_snapshot             = true

  tags = {
    Environment = "example"
  }
}
