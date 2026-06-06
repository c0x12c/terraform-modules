module "openvpn" {
  source = "../../"

  vpn_name    = "openvpn-example"
  domain_name = "example.com"

  vpc_name   = "vpc-name"
  vpc_subnet = "vpc-subnet"

  oauth2_client_id     = "id"
  oauth2_client_secret = "secret"
}
