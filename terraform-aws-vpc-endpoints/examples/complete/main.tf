module "vpc_endpoints" {
  source = "../../"

  vpc_id             = "vpc-123456"
  route_table_ids    = ["route_table_1"]
  security_group_ids = ["security_group_1"]
  subnet_ids         = ["subnet_1"]

  enable_s3  = true
  enable_sqs = true
  enable_ecr = true
  enable_eks = true
}
