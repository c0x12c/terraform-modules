/*
aws_vpc_endpoint_service (sqs) retrieves information about the Amazon Simple Queue Service (SQS) endpoint service.
The filter ensures that only Interface endpoints are selected, which enable private access to SQS within the VPC.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service
*/
data "aws_vpc_endpoint_service" "sqs" {
  count   = var.enable_sqs ? 1 : 0
  service = "sqs"

  filter {
    name   = "service-type"
    values = ["Interface"]
  }
}

/*
aws_vpc_endpoint (sqs) creates an Interface VPC endpoint in the specified VPC for the Amazon SQS service.
This endpoint allows private communication with SQS within the VPC, using specified security groups and subnets.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
*/
resource "aws_vpc_endpoint" "sqs" {
  count        = var.enable_sqs ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = data.aws_vpc_endpoint_service.sqs[0].service_name

  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = var.security_group_ids
  subnet_ids          = var.subnet_ids
}
