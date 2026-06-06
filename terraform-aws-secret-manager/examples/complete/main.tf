module "secret_manager" {
  source = "../../"

  secrets = {
    "API_KEY" = "VALUE"
    "TOKEN"   = "VALUE"
  }
}
