module "ecs" {
  source = "../../"

  cluster_name = "example"
  tags = {
    Name        = "example"
    Environment = "dev"
  }
}
