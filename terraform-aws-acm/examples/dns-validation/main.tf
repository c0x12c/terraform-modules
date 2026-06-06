module "acm" {
  source = "../../"

  zone_id     = "example"
  domain_name = "example.com"
  subject_alternative_names = [
    "*.example.com"
  ]

  wait_for_validation = false

  tags = {
    Name = "example.com"
  }
}
