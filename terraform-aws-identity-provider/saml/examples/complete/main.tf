module "saml_vpn" {
  source = "../../"

  saml_providers = {
    "example_provider"              = file("./example_saml_document") # content b64encoded
    "example_self_service_provider" = file("./example_saml_document") # content b64encoded
  }
}
