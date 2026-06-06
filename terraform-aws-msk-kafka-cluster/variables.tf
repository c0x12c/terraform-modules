variable "cluster_name" {
  description = "The name of the MSK cluster."
  type        = string
}

variable "kafka_version" {
  description = "The desired Kafka software version. Defaults to the latest MSK-supported Apache Kafka version (3.8.x)."
  type        = string
  default     = "3.8.x"
}

variable "number_of_broker_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. Must be a multiple of the number of AZs (length of subnet_ids)."
  type        = number
  default     = 3
}

variable "broker_instance_type" {
  description = "The EC2 instance type for broker nodes, e.g. kafka.m5.large or kafka.t3.small."
  type        = string
  default     = "kafka.t3.small"
}

variable "broker_ebs_volume_size" {
  description = "The size (in GiB) of the EBS volume attached to each broker."
  type        = number
  default     = 100
}

variable "subnet_ids" {
  description = "A list of subnet ids in which the broker nodes will be placed (one per AZ)."
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group ids to attach to the broker ENIs."
  type        = list(string)
}

variable "enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch metrics level. Valid values: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER, PER_TOPIC_PER_PARTITION."
  type        = string
  default     = "DEFAULT"
}

variable "storage_mode" {
  description = "Controls storage mode for supported storage tiers. Valid values: LOCAL, TIERED."
  type        = string
  default     = "LOCAL"
}

variable "encryption_at_rest_kms_key_arn" {
  description = "The ARN of the KMS key used for encryption at rest. When null, AWS managed key is used."
  type        = string
  default     = null
}

variable "encryption_in_transit_client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, PLAINTEXT."
  type        = string
  default     = "TLS"
}

variable "encryption_in_transit_in_cluster" {
  description = "Whether data communication among broker nodes is encrypted."
  type        = bool
  default     = true
}

variable "client_authentication" {
  description = "Client authentication configuration. Set any combination of sasl_iam, sasl_scram, tls_certificate_authority_arns, unauthenticated."
  type = object({
    sasl_iam                       = optional(bool, false)
    sasl_scram                     = optional(bool, false)
    tls_certificate_authority_arns = optional(list(string), null)
    unauthenticated                = optional(bool, false)
  })
  default = null
}

variable "public_access_type" {
  description = "Public access type for the cluster. Valid values: DISABLED, SERVICE_PROVIDED_EIPS."
  type        = string
  default     = "DISABLED"
}

variable "create_configuration" {
  description = "Whether to create an aws_msk_configuration and attach it to the cluster."
  type        = bool
  default     = false
}

variable "configuration_server_properties" {
  description = "Map of Kafka server properties to set when create_configuration is true."
  type        = map(string)
  default     = {}
}

variable "cloudwatch_logs_enabled" {
  description = "Whether to ship broker logs to CloudWatch. When true, a log group is created."
  type        = bool
  default     = false
}

variable "cloudwatch_log_retention_in_days" {
  description = "Retention (in days) for the CloudWatch broker log group."
  type        = number
  default     = 30
}

variable "jmx_exporter_enabled" {
  description = "Whether the JMX Prometheus exporter is enabled on each broker."
  type        = bool
  default     = false
}

variable "node_exporter_enabled" {
  description = "Whether the node Prometheus exporter is enabled on each broker."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to all created resources."
  type        = map(string)
  default     = {}
}
