module "documentdb" {
  source = "../../"

  name            = "example-docdb"
  master_username = "docdbadmin"
  database_name   = "app"

  vpc_id  = "vpc-0123456789abcdef0"
  subnets = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

  instance_class = "db.t3.medium"
  instance_count = 1

  tls_enabled = true

  security_group_rules = {
    eks = {
      source_security_group_id = "sg-0123456789abcdef0"
    }
    office = {
      cidr_blocks = ["10.0.0.0/16"]
    }
  }

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = {
    Environment = "dev"
  }
}
