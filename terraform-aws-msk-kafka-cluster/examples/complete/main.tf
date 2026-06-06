module "msk" {
  source = "../../"

  cluster_name           = "example"
  kafka_version          = "3.8.x"
  number_of_broker_nodes = 3
  broker_instance_type   = "kafka.t3.small"
  broker_ebs_volume_size = 100

  subnet_ids         = ["subnet-1234567899a", "subnet-1234567899b", "subnet-1234567899c"]
  security_group_ids = ["sg-1234567899"]

  encryption_in_transit_client_broker = "TLS"
  enhanced_monitoring                 = "PER_BROKER"
  cloudwatch_logs_enabled             = true

  client_authentication = {
    sasl_iam = true
  }

  create_configuration = true
  configuration_server_properties = {
    "auto.create.topics.enable"  = "true"
    "default.replication.factor" = "3"
    "min.insync.replicas"        = "2"
    "num.partitions"             = "3"
  }

  tags = {
    Environment = "dev"
  }
}
