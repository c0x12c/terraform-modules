module "aws_vpc" {
  source = "../.."

  name                        = "example"
  cidr_block                  = "10.0.1.0/16"
  availability_zone_postfixes = ["a", "b", "c"]
  single_nat                  = true
  region                      = "us-west-2"
}
