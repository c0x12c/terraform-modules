locals {
  region                  = var.region != null ? var.region : data.aws_region.current.name
  fluent_bit_config_outut = <<EOF
[OUTPUT]
    Name cloudwatch_logs
    Match   *
    region ${local.region}
    log_group_name awslogs-eks
    log_stream_prefix awslogs-eks-firelens-
    log_retention_days 30
    auto_create_group true
EOF
}
