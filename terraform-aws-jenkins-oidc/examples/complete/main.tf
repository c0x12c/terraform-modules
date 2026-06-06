module "jenkins_oidc" {
  source = "../../"

  role_name = "jenkins"
  url       = "https://jenkins.example.com/oidc"
}
