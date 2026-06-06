output "saml_provider_arn" {
  value = module.saml_vpn.saml_providers["example_provider"]
}

output "self_service_saml_provider_arn" {
  value = module.saml_vpn.saml_providers["example_self_service_provider"]
}
