/*
aws_cloudwatch_log_group holds broker logs when cloudwatch_logs_enabled is true.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
*/
resource "aws_cloudwatch_log_group" "this" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  name              = "/aws/msk/${var.cluster_name}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.tags
}

/*
aws_msk_configuration defines Kafka server properties that can be attached to the cluster.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration
*/
resource "aws_msk_configuration" "this" {
  count = var.create_configuration ? 1 : 0

  name           = var.cluster_name
  kafka_versions = [var.kafka_version]

  server_properties = join("\n", [for k, v in var.configuration_server_properties : "${k} = ${v}"])

  lifecycle {
    create_before_destroy = true
  }
}

/*
aws_msk_cluster provisions an Amazon MSK (Managed Streaming for Kafka) cluster.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster
*/
resource "aws_msk_cluster" "this" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  enhanced_monitoring    = var.enhanced_monitoring
  storage_mode           = var.storage_mode

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.subnet_ids
    security_groups = var.security_group_ids

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_ebs_volume_size
      }
    }

    connectivity_info {
      public_access {
        type = var.public_access_type
      }
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn

    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
  }

  dynamic "client_authentication" {
    for_each = var.client_authentication != null ? [var.client_authentication] : []

    content {
      unauthenticated = client_authentication.value.unauthenticated

      dynamic "sasl" {
        for_each = client_authentication.value.sasl_iam || client_authentication.value.sasl_scram ? [1] : []
        content {
          iam   = client_authentication.value.sasl_iam
          scram = client_authentication.value.sasl_scram
        }
      }

      dynamic "tls" {
        for_each = client_authentication.value.tls_certificate_authority_arns != null ? [1] : []
        content {
          certificate_authority_arns = client_authentication.value.tls_certificate_authority_arns
        }
      }
    }
  }

  dynamic "configuration_info" {
    for_each = var.create_configuration ? [1] : []

    content {
      arn      = aws_msk_configuration.this[0].arn
      revision = aws_msk_configuration.this[0].latest_revision
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.jmx_exporter_enabled
      }
      node_exporter {
        enabled_in_broker = var.node_exporter_enabled
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.cloudwatch_logs_enabled
        log_group = var.cloudwatch_logs_enabled ? aws_cloudwatch_log_group.this[0].name : null
      }
    }
  }

  tags = var.tags

  # MSK auto-scaled EBS volume changes should not drift the plan.
  lifecycle {
    ignore_changes = [
      broker_node_group_info[0].storage_info[0].ebs_storage_info[0].volume_size,
    ]
  }
}
