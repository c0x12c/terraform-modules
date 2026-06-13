module "example" {
  source = "../../"

  name = "example"
  tags = {
    Environment = "dev"
  }
}
