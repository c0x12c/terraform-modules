variable "alias_name" {
  description = "A list of aliases to create. Note - due to the use of `toset()`, values must be static strings and not computed values."
  type        = list(string)
  default     = []
}

variable "description" {
  description = "The description of the key as viewed in AWS console."
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days."
  type        = number
  default     = 7
}

variable "key_usage" {
  description = "Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "custom_key_store_id" {
  description = "ID of the KMS Custom Key Store where the key will be stored instead of KMS (eg CloudHSM)."
  type        = string
  default     = null
}

variable "customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, HMAC_256, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled. Required to be enabled if rotation_period_in_days is specified."
  type        = bool
  default     = false
}

variable "rotation_period_in_days" {
  description = "Custom period of time between each rotation date. Must be a number between 90 and 2560."
  type        = number
  default     = 90
}

variable "enabled_create_policy" {
  description = "Specifies whether policy need to be created."
  type        = bool
  default     = false
}

variable "principal_roles" {
  description = "A list of IAM roles that a specific principal (user, service, or account) can assume."
  type        = list(string)
  default     = null
}

variable "additional_statements" {
  description = "List of additional statements for KMS policy."
  type = list(object({
    effect      = string
    type        = string
    identifiers = list(string)
    actions     = list(string)
    resources   = list(string)
    condition = object({
      test     = string
      variable = string
      values   = list(string)
    })
  }))
  default = null
}
