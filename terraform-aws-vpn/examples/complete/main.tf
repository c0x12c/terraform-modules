module "vpn" {
  source = "../../"

  endpoint_name                  = "example"
  endpoint_client_cidr_block     = "172.16.0.0/20"
  endpoint_subnets               = ["subnet-12345678a"] # private subnet
  endpoint_vpc_id                = "vpc-04b6207e33a2a62cb"
  saml_provider_arn              = "arn:aws:iam::123456788901:saml-provider/aws-client-vpn"
  self_service_saml_provider_arn = "arn:aws:iam::123456788901:saml-provider/aws-client-vpn-self-service"
  certificate_arn                = "arn:aws:acm:us-east-1:123456788901:certificate/abcd1234-ab12-cd34-ef56-abcdef123456"
  additional_routes = [
    {
      subnet_id              = "subnet-12345678a"
      destination_cidr_block = "0.0.0.0/0"
    },
  ]
}
