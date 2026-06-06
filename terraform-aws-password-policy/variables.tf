variable "minimum_password_length" {
  type        = number
  default     = 8
  description = "The minimum number of characters required for a password."
}

variable "require_lowercase_characters" {
  type        = bool
  default     = true
  description = "Specifies if a password must contain at least one lowercase letter."
}

variable "require_numbers" {
  type        = bool
  default     = true
  description = "Specifies if a password must contain at least one numeric character."
}

variable "require_uppercase_characters" {
  type        = bool
  default     = true
  description = "Specifies if a password must contain at least one uppercase letter."
}

variable "require_symbols" {
  type        = bool
  default     = true
  description = "Specifies if a password must contain at least one special symbol."
}

variable "allow_users_to_change_password" {
  type        = bool
  default     = true
  description = "Indicates whether users are allowed to change their own passwords."
}
