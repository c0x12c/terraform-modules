variable "saml_providers" {
  description = "A map of SAML providers name and SAML metadata document content."
  type        = map(string)
}
