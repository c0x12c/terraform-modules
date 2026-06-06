variable "cert_map" {
  description = "The Google-managed SSL certificate name used to secure GKE gateway, reference: `https://cloud.google.com/kubernetes-engine/docs/how-to/secure-gateway#secure-using-ssl-certificate`."
  type        = string
}

variable "namespace" {
  description = "The namespace name to create gateway within."
  type        = string
  default     = "gateway-api"
}

variable "create_namespace" {
  description = "Specifies whether to create a new namespace."
  type        = bool
  default     = true
}

variable "create_duration" {
  description = "Specifies time to wait for resource creation."
  type        = string
  default     = "300s"
}

variable "ext_gateway_name" {
  description = "The gateway name to be created."
  type        = string
  default     = "external-gateway"
}

variable "ext_gateway_class_name" {
  description = "The gateway class name, reference: `https://cloud.google.com/kubernetes-engine/docs/how-to/gatewayclass-capabilities`."
  type        = string
  default     = "gke-l7-global-external-managed"
}

variable "enabled_field_manager" {
  description = "Specifies whether to enable field manager for the resource."
  type        = bool
  default     = false
}