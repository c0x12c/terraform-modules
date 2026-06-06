module "redis_cluster" {
  source = "../../"

  name   = "redis-cluster-name"
  region = "us-west1"
  vpc_id = "example-vpc-id"

  node_type               = "REDIS_SHARED_CORE_NANO"
  authorization_mode      = "AUTH_MODE_DISABLED"
  transit_encryption_mode = "TRANSIT_ENCRYPTION_MODE_DISABLED"
}
