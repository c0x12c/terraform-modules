# AWS MSK Kafka Cluster Terraform module

Terraform module which creates an Amazon MSK (Managed Streaming for Apache Kafka) cluster.

This module will create the following components:

- An MSK cluster with broker nodes across the provided subnets
- Optional MSK configuration with custom server properties
- Optional CloudWatch log group for broker logs
- Encryption at rest (optional KMS CMK) and in transit
- Open monitoring (JMX / node exporter) for Prometheus

## Usage

### Create MSK cluster

```hcl
module "msk" {
  source  = "c0x12c/msk-kafka-cluster/aws"
  version = "0.1.0"

  cluster_name           = "example"
  kafka_version          = "3.8.x"
  number_of_broker_nodes = 3
  broker_instance_type   = "kafka.t3.small"
  broker_ebs_volume_size = 100

  subnet_ids         = ["subnet-1234567899a", "subnet-1234567899b", "subnet-1234567899c"]
  security_group_ids = ["sg-1234567899"]

  client_authentication = {
    sasl_iam = true
  }

  tags = {
    Environment = "dev"
  }
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_msk_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster) | resource |
| [aws_msk_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_broker_ebs_volume_size"></a> [broker\_ebs\_volume\_size](#input\_broker\_ebs\_volume\_size) | The size (in GiB) of the EBS volume attached to each broker. | `number` | `100` | no |
| <a name="input_broker_instance_type"></a> [broker\_instance\_type](#input\_broker\_instance\_type) | The EC2 instance type for broker nodes, e.g. kafka.m5.large or kafka.t3.small. | `string` | `"kafka.t3.small"` | no |
| <a name="input_client_authentication"></a> [client\_authentication](#input\_client\_authentication) | Client authentication configuration. Set any combination of sasl\_iam, sasl\_scram, tls\_certificate\_authority\_arns, unauthenticated. | <pre>object({<br/>    sasl_iam                       = optional(bool, false)<br/>    sasl_scram                     = optional(bool, false)<br/>    tls_certificate_authority_arns = optional(list(string), null)<br/>    unauthenticated                = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_cloudwatch_log_retention_in_days"></a> [cloudwatch\_log\_retention\_in\_days](#input\_cloudwatch\_log\_retention\_in\_days) | Retention (in days) for the CloudWatch broker log group. | `number` | `30` | no |
| <a name="input_cloudwatch_logs_enabled"></a> [cloudwatch\_logs\_enabled](#input\_cloudwatch\_logs\_enabled) | Whether to ship broker logs to CloudWatch. When true, a log group is created. | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the MSK cluster. | `string` | n/a | yes |
| <a name="input_configuration_server_properties"></a> [configuration\_server\_properties](#input\_configuration\_server\_properties) | Map of Kafka server properties to set when create\_configuration is true. | `map(string)` | `{}` | no |
| <a name="input_create_configuration"></a> [create\_configuration](#input\_create\_configuration) | Whether to create an aws\_msk\_configuration and attach it to the cluster. | `bool` | `false` | no |
| <a name="input_encryption_at_rest_kms_key_arn"></a> [encryption\_at\_rest\_kms\_key\_arn](#input\_encryption\_at\_rest\_kms\_key\_arn) | The ARN of the KMS key used for encryption at rest. When null, AWS managed key is used. | `string` | `null` | no |
| <a name="input_encryption_in_transit_client_broker"></a> [encryption\_in\_transit\_client\_broker](#input\_encryption\_in\_transit\_client\_broker) | Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS\_PLAINTEXT, PLAINTEXT. | `string` | `"TLS"` | no |
| <a name="input_encryption_in_transit_in_cluster"></a> [encryption\_in\_transit\_in\_cluster](#input\_encryption\_in\_transit\_in\_cluster) | Whether data communication among broker nodes is encrypted. | `bool` | `true` | no |
| <a name="input_enhanced_monitoring"></a> [enhanced\_monitoring](#input\_enhanced\_monitoring) | Specify the desired enhanced MSK CloudWatch metrics level. Valid values: DEFAULT, PER\_BROKER, PER\_TOPIC\_PER\_BROKER, PER\_TOPIC\_PER\_PARTITION. | `string` | `"DEFAULT"` | no |
| <a name="input_jmx_exporter_enabled"></a> [jmx\_exporter\_enabled](#input\_jmx\_exporter\_enabled) | Whether the JMX Prometheus exporter is enabled on each broker. | `bool` | `false` | no |
| <a name="input_kafka_version"></a> [kafka\_version](#input\_kafka\_version) | The desired Kafka software version. Defaults to the latest MSK-supported Apache Kafka version (3.8.x). | `string` | `"3.8.x"` | no |
| <a name="input_node_exporter_enabled"></a> [node\_exporter\_enabled](#input\_node\_exporter\_enabled) | Whether the node Prometheus exporter is enabled on each broker. | `bool` | `false` | no |
| <a name="input_number_of_broker_nodes"></a> [number\_of\_broker\_nodes](#input\_number\_of\_broker\_nodes) | The desired total number of broker nodes in the kafka cluster. Must be a multiple of the number of AZs (length of subnet\_ids). | `number` | `3` | no |
| <a name="input_public_access_type"></a> [public\_access\_type](#input\_public\_access\_type) | Public access type for the cluster. Valid values: DISABLED, SERVICE\_PROVIDED\_EIPS. | `string` | `"DISABLED"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of security group ids to attach to the broker ENIs. | `list(string)` | n/a | yes |
| <a name="input_storage_mode"></a> [storage\_mode](#input\_storage\_mode) | Controls storage mode for supported storage tiers. Valid values: LOCAL, TIERED. | `string` | `"LOCAL"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet ids in which the broker nodes will be placed (one per AZ). | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all created resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_brokers"></a> [bootstrap\_brokers](#output\_bootstrap\_brokers) | Comma-separated list of plaintext broker endpoints. |
| <a name="output_bootstrap_brokers_sasl_iam"></a> [bootstrap\_brokers\_sasl\_iam](#output\_bootstrap\_brokers\_sasl\_iam) | Comma-separated list of SASL/IAM broker endpoints. |
| <a name="output_bootstrap_brokers_sasl_scram"></a> [bootstrap\_brokers\_sasl\_scram](#output\_bootstrap\_brokers\_sasl\_scram) | Comma-separated list of SASL/SCRAM broker endpoints. |
| <a name="output_bootstrap_brokers_tls"></a> [bootstrap\_brokers\_tls](#output\_bootstrap\_brokers\_tls) | Comma-separated list of TLS broker endpoints. |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group created for broker logs, if any. |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The ARN of the MSK cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the MSK cluster. |
| <a name="output_configuration_arn"></a> [configuration\_arn](#output\_configuration\_arn) | ARN of the MSK configuration created by this module, if any. |
| <a name="output_configuration_latest_revision"></a> [configuration\_latest\_revision](#output\_configuration\_latest\_revision) | Latest revision of the MSK configuration created by this module, if any. |
| <a name="output_current_version"></a> [current\_version](#output\_current\_version) | The current version of the MSK cluster. Used for in-place updates. |
| <a name="output_zookeeper_connect_string"></a> [zookeeper\_connect\_string](#output\_zookeeper\_connect\_string) | A comma-separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster. |
<!-- END_TF_DOCS -->
