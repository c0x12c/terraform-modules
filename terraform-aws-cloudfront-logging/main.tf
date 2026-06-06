resource "aws_cloudwatch_log_delivery_source" "this" {
  name         = "${var.name}-cloudfront-source"
  log_type     = "ACCESS_LOGS"
  resource_arn = var.aws_cloudfront_distribution_arn
}

resource "aws_cloudwatch_log_delivery_destination" "this" {
  name = "${var.name}-cloudfront-destination"
  delivery_destination_configuration {
    destination_resource_arn = var.log_bucket_arn
  }
}

resource "aws_cloudwatch_log_delivery" "this" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.this.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.this.arn

  s3_delivery_configuration {
    suffix_path = "${var.name}/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
  }
}
