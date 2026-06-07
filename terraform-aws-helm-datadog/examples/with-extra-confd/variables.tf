variable "environment" {
  description = "Environment where the resources will be created."
  type        = string
}

variable "cluster_name" {
  description = "The EKS cluster name."
  type        = string
}

variable "datadog_api_key" {
  description = "The datadog api key."
  type        = string
}

variable "datadog_app_key" {
  description = "The datadog app key."
  type        = string
}

variable "datadog_site" {
  description = "The datadog site."
  type        = string
}
