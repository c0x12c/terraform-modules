output "endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = [aws_vpc_endpoint.ecr_api, aws_vpc_endpoint.ecr_dkr, aws_vpc_endpoint.s3, aws_vpc_endpoint.sqs]
}
