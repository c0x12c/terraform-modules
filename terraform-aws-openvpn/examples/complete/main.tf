module "openvpn" {
  source = "../.."

  vpn_name    = "openvpn"
  domain_name = "example.com"

  vpc_id       = "vpc-123456789"
  subnet_id    = "subnet-123456789"
  extra_sg_ids = ["sg-123456789"]

  oauth2_client_id     = "google_client_id"
  oauth2_client_secret = "google_client_secret"
}
