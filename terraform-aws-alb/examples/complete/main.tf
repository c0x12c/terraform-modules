module "alb" {
  source = "../../"

  name              = "example"
  vpc_id            = "vpc-1234567899"
  public_subnets    = []
  security_groups   = ["sg-1234567899"]
  certificate_arn   = ""
  health_check_path = "/health"
  idle_timeout      = 4000
  internal          = false
  tags = {
    Environment = "dev"
  }
}
