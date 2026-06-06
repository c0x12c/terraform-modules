/*
aws_vpc_endpoint_service (ecr_api) fetches information about the Amazon Elastic Container Registry (ECR) API endpoint service.
The service filter ensures that only Interface endpoints are selected.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service
*/
data "aws_vpc_endpoint_service" "ecr_api" {
  count   = var.enable_ecr ? 1 : 0
  service = "ecr.api"

  filter {
    name   = "service-type"
    values = ["Interface"]
  }
}

/*
aws_vpc_endpoint_service (ecr_dkr) fetches information about the Amazon Elastic Container Registry Docker (ECR DKR) endpoint service.
The service filter ensures that only Interface endpoints are selected.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service
*/
data "aws_vpc_endpoint_service" "ecr_dkr" {
  count   = var.enable_ecr ? 1 : 0
  service = "ecr.dkr"

  filter {
    name   = "service-type"
    values = ["Interface"]
  }
}

/*
aws_vpc_endpoint (ecr_api) creates an Interface VPC endpoint in the specified VPC for the ECR API service.
This endpoint allows private communication with the ECR API service within the VPC.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
*/
resource "aws_vpc_endpoint" "ecr_api" {
  count        = var.enable_ecr ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = data.aws_vpc_endpoint_service.ecr_api[0].service_name

  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = var.security_group_ids
  subnet_ids          = var.subnet_ids
}

/*
aws_vpc_endpoint (ecr_dkr) creates an Interface VPC endpoint in the specified VPC for the ECR Docker (ECR DKR) service.
This endpoint allows private communication with the ECR DKR service within the VPC.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
*/
resource "aws_vpc_endpoint" "ecr_dkr" {
  count        = var.enable_ecr ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = data.aws_vpc_endpoint_service.ecr_dkr[0].service_name

  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = var.security_group_ids
  subnet_ids          = var.subnet_ids
}
