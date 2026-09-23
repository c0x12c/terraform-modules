module "datadog_aws_integration" {
  source = "../../"

  # Default is null (collect all namespaces). Set to a list to restrict collection:
  namespace_filters_include_only = [
    "AWS/EC2",
    "AWS/ECS",
    "AWS/EKS",
    "AWS/ElastiCache",
    "AWS/Lambda",
    "AWS/RDS",
    "AWS/S3",
  ]

  # Default is [] (no account tags). Set tags to add them to every metric from this account:
  account_tags = []
}
