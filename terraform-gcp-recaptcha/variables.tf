variable "project_id" {
  description = "The ID of the GCP project where the resources will be created."
  type        = string
}

variable "environment" {
  description = "Environment where the resources will be created."
  type        = string
}

variable "allow_all_package_names" {
  description = "Android settings. If set to true, it means allowed_package_names will not be enforced."
  type        = bool
  default     = true
}

variable "allowed_package_names" {
  description = "Android settings. Android package names of apps allowed to use the key. Example: 'com.companyname.appname'."
  type        = list(string)
  default     = []
}

variable "allow_all_bundle_ids" {
  description = "iOS settings. If set to true, it means allowed_bundle_ids will not be enforced."
  type        = bool
  default     = true
}

variable "allowed_bundle_ids" {
  description = "iOS settings. iOS bundle ids of apps allowed to use the key. Example: 'com.companyname.productname.appname'."
  type        = list(string)
  default     = []
}
