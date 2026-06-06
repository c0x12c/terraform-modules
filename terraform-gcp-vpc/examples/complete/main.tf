module "vpc" {
  source = "../../"

  vpc_name                = "example-vpc"
  region                  = "us-west1"
  application_subnet_cidr = "10.10.0.0/20"
  services_subnet_cidr    = "10.10.16.0/24"
  pods_subnet_cidr        = "10.10.32.0/20"
  data_subnet_cidr        = "10.20.10.0/24"

  nat_ip_address_name = "example-nat"
  router_name         = "example-router"
}
