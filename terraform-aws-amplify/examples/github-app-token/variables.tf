variable "github_app_id" {
  description = "GitHub App id the installation token is minted for."
  type        = string
}

variable "github_app_installation_id" {
  description = "Installation id of that App on the organization owning the repository."
  type        = string
}

variable "github_app_pem_file" {
  description = "PKCS#1 private key for the App. Read it from a file or a secret store - never commit it."
  type        = string
  sensitive   = true
}
