variable "name" {
  type        = string
  description = "Qdrant cluster name"
}

variable "cloud_provider" {
  type        = string
  default     = "aws"
  description = "Cloud provider to use for the Qdrant cluster"
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "Region to deploy the Qdrant cluster"
}

variable "number_of_nodes" {
  type        = number
  default     = 1
  description = "Number of nodes in the Qdrant cluster"
}

# Get list node package from
# curl --location 'https://cloud.qdrant.io/pa/v1/booking/packages?provider=aws&region=us-west-2' --header 'Authorization: apiKey <apiKey>'
variable "node_package_id" {
  type        = string
  description = "Node package ID to use for the Qdrant cluster"
}
