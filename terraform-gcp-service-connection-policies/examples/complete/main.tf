module "service_connection_policies" {
  source = "../../"

  gcp_region = "us-west-1"
  subnet_id  = "<subnet-id>"
  vpc_id     = "<vpc-id>"
  policies = {
    policy1 = {
      description   = "Policy for service A"
      service_class = "service-class-a"
    },
    policy2 = {
      description   = "Policy for service B"
      service_class = "service-class-b"
    }
  }
}
