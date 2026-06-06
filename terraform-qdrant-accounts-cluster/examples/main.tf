module "qdrant" {
  source          = "../"
  cloud_provider  = "aws"
  region          = "us-west-2"
  number_of_nodes = 1
  node_package_id = "uuid-of-a-node-package"
  name            = "qdrant-cluster"
}
