module "password_generator" {
  source = "../../"

  secret_name = "secret"
  tags = {
    Name = "secret"
  }
}
