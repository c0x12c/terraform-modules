module "cluster" {
  source = "../../"

  name            = "example-aurora-sv2"
  engine          = "aurora-postgresql"
  engine_version  = "17.9"
  database_name   = "exampledb"
  master_username = "exampleuser"

  vpc_id  = "vpc-123456789"
  subnets = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 4
  }

  instances = {
    main = {}
  }

  db_cluster_parameter_group_family = "aurora-postgresql17"

  deletion_protection = false
  skip_final_snapshot = true
}
