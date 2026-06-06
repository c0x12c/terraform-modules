module "opensearch" {
  source = "../../"

  domain             = "opensearch"
  instance_size      = "t3.small.search"
  engine_version     = "OpenSearch_2.13"
  instance_count     = 1
  ebs_enabled        = true
  security_group_ids = ["security_group_1"]
  subnet_ids         = ["subnet_id_1"]
}

