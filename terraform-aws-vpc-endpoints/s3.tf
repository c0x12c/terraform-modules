/*
aws_vpc_endpoint_service (s3) fetches details about the Amazon S3 endpoint service.
The service filter specifies a Gateway endpoint, which allows access to S3 from within the VPC without requiring public internet access.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service
*/
data "aws_vpc_endpoint_service" "s3" {
  count   = var.enable_s3 ? 1 : 0
  service = "s3"

  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}

/*
aws_vpc_endpoint (s3) creates a Gateway VPC endpoint in the specified VPC for the Amazon S3 service.
This endpoint provides private access to S3 without needing an internet gateway, NAT device, or VPN connection.
The endpoint is associated with the specified route tables in the VPC.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
*/
resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_s3 ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name

  route_table_ids = var.route_table_ids
}
