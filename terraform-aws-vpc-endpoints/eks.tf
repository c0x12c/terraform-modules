/*
aws_vpc_endpoint_service (EKS) fetches details about the Amazon EKS endpoint service.
The service filter specifies a Gateway endpoint, which allows access to EKS from within the VPC without requiring public internet access.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service
*/
data "aws_vpc_endpoint_service" "eks" {
  count   = var.enable_eks ? 1 : 0
  service = "eks"

  filter {
    name   = "service-type"
    values = ["Interface"]
  }
}

/*
aws_vpc_endpoint (EKS) creates a Gateway VPC endpoint in the specified VPC for the Amazon EKS service.
This endpoint provides private access to EKS without needing an internet gateway, NAT device, or VPN connection.
The endpoint is associated with the specified route tables in the VPC.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
*/
resource "aws_vpc_endpoint" "eks" {
  count        = var.enable_eks ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = data.aws_vpc_endpoint_service.eks[0].service_name

  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = var.security_group_ids
  subnet_ids          = var.subnet_ids
}
