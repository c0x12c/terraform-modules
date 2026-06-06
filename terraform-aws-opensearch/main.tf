/*
aws_opensearch_domain provisions an Amazon OpenSearch Service domain, configuring cluster, storage, and network settings.
The `domain_name`, `engine_version`, instance configuration, and security settings are specified by variables to enable customization.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain
*/
resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain
  engine_version = var.engine_version
  cluster_config {
    instance_type  = var.instance_size
    instance_count = var.instance_count

    zone_awareness_enabled = var.zone_awareness_enabled
    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }
  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.ebs_storage_size
  }
  encrypt_at_rest {
    enabled = var.encrypt_at_rest_enabled
  }
  domain_endpoint_options {
    enforce_https       = var.enforce_https
    tls_security_policy = var.tls_security_policy
  }
  access_policies = data.aws_iam_policy_document.this.json
}

resource "aws_iam_service_linked_role" "opensearch" {
  count = var.create_linked_role ? 1 : 0

  aws_service_name = "es.amazonaws.com"
}
