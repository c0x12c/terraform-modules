resource "aws_service_discovery_private_dns_namespace" "this" {
  name = local.cluster_name
  vpc  = aws_vpc.this.id
}
