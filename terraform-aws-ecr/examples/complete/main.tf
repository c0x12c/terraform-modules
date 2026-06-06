module "ecr" {
  source = "../../"

  name = "example-repo"

  tags = {
    Name = "example-repo"
  }
}
