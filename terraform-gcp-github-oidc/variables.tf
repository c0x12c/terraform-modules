variable "gcp_pool_id" {
  description = "The ID of the GCP node pool where resources will be deployed."
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID under which the resources are managed."
  type        = string
}

variable "gcp_provider_id" {
  description = "The ID of the GCP provider used for managing infrastructure."
  type        = string
}

variable "gcp_service_account_id" {
  description = "The ID of the GCP service account used for authentication and permissions."
  type        = string
}

variable "github_repos" {
  description = "A list of GitHub repositories to be managed or integrated."
  type        = list(any)
  default     = []
}

variable "github_org" {
  description = "The GitHub organization where the repositories are located."
  type        = string
}
