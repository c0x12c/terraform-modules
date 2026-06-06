variable "gcp_region" {
  description = "The Google Cloud region where resources will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the service connection will be established with format `projects/{{project}}/regions/{{region}}/subnetworks/{{name}}`."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC network to which the service connection policy applies."
  type        = string
}

variable "policies" {
  description = "A map of service connection policies, each defined by a description and service class."
  type = map(object({
    description   = string
    service_class = string
  }))
  default = {}
}
