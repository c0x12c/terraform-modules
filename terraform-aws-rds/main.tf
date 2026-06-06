data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_db_subnet_group" "this" {
  description = local.db_subnet_group_description
  name        = local.db_subnet_group_name
  subnet_ids  = var.subnet_ids
}

resource "aws_security_group" "this" {
  name        = "Allow ${local.identifier} RDS"
  description = "Allow RDS inbound traffic and outbound traffic inside the VPC"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = data.aws_vpc.this.cidr_block
  from_port         = var.port
  ip_protocol       = "tcp"
  to_port           = var.port
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

module "main_db_instance" {
  source                       = "./db_instance"
  identifier                   = local.identifier
  instance_class               = var.instance_class
  allocated_storage            = var.disk_size
  max_allocated_storage        = var.max_allocated_storage
  backup_retention_period      = local.default_backup_retention
  skip_final_snapshot          = var.skip_final_snapshot
  storage_type                 = var.storage_type
  storage_encrypted            = var.storage_encrypted
  engine                       = var.engine
  engine_version               = var.engine_version
  username                     = var.db_username
  password                     = local.db_password
  db_name                      = var.db_name
  port                         = var.port
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.this.id]
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = var.apply_immediately
  monitoring_interval          = var.monitoring_interval
  performance_insights_enabled = var.performance_insights_enabled
  parameter_group_name         = aws_db_parameter_group.parameter_group[local.engine_version_major].id
  publicly_accessible          = var.publicly_accessible
  final_snapshot_identifier    = local.db_final_snapshot_identifier
  copy_tags_to_snapshot        = var.copy_tags_to_snapshot
  multi_az                     = var.multi_az
  deletion_protection          = var.primary_deletion_protection

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  cloudwatch_exported_log_types = var.cloudwatch_exported_log_types
}

module "replica_db_instance" {
  source                       = "./db_instance"
  count                        = var.replica_count
  identifier                   = "${local.identifier}-replica-${count.index}"
  instance_class               = var.instance_class
  allocated_storage            = var.disk_size
  max_allocated_storage        = var.max_allocated_storage
  backup_retention_period      = "0"
  skip_final_snapshot          = var.skip_final_snapshot
  storage_type                 = var.storage_type
  storage_encrypted            = var.storage_encrypted
  engine                       = var.engine
  engine_version               = var.engine_version
  port                         = var.port
  vpc_security_group_ids       = [aws_security_group.this.id]
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = var.apply_immediately
  monitoring_interval          = var.monitoring_interval
  performance_insights_enabled = var.performance_insights_enabled
  parameter_group_name         = aws_db_parameter_group.parameter_group[local.engine_version_major].id
  publicly_accessible          = var.publicly_accessible
  replicate_source_db          = module.main_db_instance.db_identifier
  deletion_protection          = var.replica_deletion_protection

  cloudwatch_exported_log_types = var.cloudwatch_exported_log_types
}
