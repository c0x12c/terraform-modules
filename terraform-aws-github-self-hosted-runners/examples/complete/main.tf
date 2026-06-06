module "github_self_host_runner" {
  source = "../../"

  github_actions_runner_registration_token = "example"
  org_name                                 = "example"
  security_group_ids                       = ["sg-1234567890abcdef0"]
  custom_ami_name                          = "example"
  subnet_ids                               = ["subnet-12345678", "subnet-87654321"]
}
