module "postgresql" {
  source = "../../"

  network_name = "example-vpc-name"
  project_id   = "example-project"
  region       = "us-west1"

  db_name  = "example-database"
  name     = "example"
  size     = 20
  username = "example-user"

  database_flags = {
    "max_connection" = "100"
  }

  database_replica_flags = {
    "max_connection" = "400"
  }

  replica_count          = 1
  analytic_replica_count = 1
}
