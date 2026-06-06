variable "project_id" {
  description = "The name of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "repository_id" {
  description = "The artifact repository name."
  type        = string
}

variable "location" {
  description = "The name of the location this repository is located in."
  type        = string
}

variable "format" {
  description = "The format of packages that are stored in the repository. Possible values are: DOCKER, MAVEN, NPM, PYTHON, APT, YUM, KUBEFLOW, GO, GENERIC."
  type        = string
  validation {
    condition     = var.format == "DOCKER" || var.format == "MAVEN" || var.format == "NPM" || var.format == "PYTHON" || var.format == "APT" || var.format == "YUM" || var.format == "KUBEFLOW" || var.format == "GO" || var.format == "GENERIC"
    error_message = "The supported values are DOCKER, MAVEN, NPM, PYTHON, APT, YUM, KUBEFLOW, GO, GENERIC."
  }
}

variable "mode" {
  description = "The mode configures the repository to serve artifacts from different sources. Default value is STANDARD_REPOSITORY. Possible values are: STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, REMOTE_REPOSITORY."
  type        = string
  default     = "STANDARD_REPOSITORY"
  validation {
    condition     = var.mode == "STANDARD_REPOSITORY" || var.mode == "VIRTUAL_REPOSITORY" || var.mode == "REMOTE_REPOSITORY"
    error_message = "The supported values are STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, REMOTE_REPOSITORY."
  }
}

variable "description" {
  description = "The user-provided description of the repository."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels for the repository."
  type        = map(string)
  default     = {}
}

variable "kms_key_name" {
  description = "The Cloud KMS (Key Management Service) resource name of the customer managed encryption key that’s used to encrypt the contents of the repository. Has the form: projects/my-project/locations/my-region/keyRings/my-kr/cryptoKeys/my-key. This value may not be changed after the repository has been created."
  type        = string
  default     = null
}

variable "docker_config" {
  description = "Docker repository config contains repository level configuration for the repositories of docker type."
  type = object({
    immutable_tags = optional(bool)
  })
  default = null
}

variable "maven_config" {
  description = "MavenRepositoryConfig is maven related repository details. Provides additional configuration details for repositories of the maven format type."
  type = object({
    allow_snapshot_overwrites = optional(bool)
    version_policy            = optional(string)
  })
  default = null
}

variable "virtual_repository_config" {
  description = "Configuration specific for a Virtual Repository."
  type = object({
    upstream_policies = optional(list(object({
      id         = string
      repository = string
      priority   = number
    })), null)
  })
  default = null
}

variable "remote_repository_config" {
  description = "Configuration specific for a Remote Repository."
  type = object({
    description = optional(string)
    apt_repository = optional(object({
      public_repository = optional(object({
        repository_base = string
        repository_path = string
      }), null)
    }), null)
    docker_repository = optional(object({
      public_repository = optional(string, "DOCKER_HUB")
    }), null)
    maven_repository = optional(object({
      public_repository = optional(string, "MAVEN_CENTRAL")
    }), null)
    npm_repository = optional(object({
      public_repository = optional(string, "NPMJS")
    }), null)
    python_repository = optional(object({
      public_repository = optional(string, "PYPI")
    }), null)
    yum_repository = optional(object({
      public_repository = optional(object({
        repository_base = string
        repository_path = string
      }), null)
    }), null)
  })
  default = null
}

variable "cleanup_policy_dry_run" {
  description = "If true, the cleanup pipeline is prevented from deleting versions in this repository."
  type        = bool
  default     = false
}

variable "cleanup_policies" {
  description = "Cleanup policies for this repository. Cleanup policies indicate when certain package versions can be automatically deleted. Map keys are policy IDs supplied by users during policy creation. They must unique within a repository and be under 128 characters in length."
  type = map(object({
    action = optional(string)
    condition = optional(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string))
      version_name_prefixes = optional(list(string))
      package_name_prefixes = optional(list(string))
      older_than            = optional(string)
      newer_than            = optional(string)
    }), null)
    most_recent_versions = optional(object({
      package_name_prefixes = optional(list(string))
      keep_count            = optional(number)
    }), null)
  }))
  default = {}
}

variable "enable_vpcsc_policy" {
  description = "Enable VPC Service Control policy."
  type        = bool
  default     = false
}

variable "vpcsc_policy" {
  description = "The VPC Service Control policy for project and location. Possible values are: DENY, ALLOW."
  type        = string
  default     = "ALLOW"
  validation {
    condition     = var.vpcsc_policy == "ALLOW" || var.vpcsc_policy == "DENY"
    error_message = "The supported values are ALLOW or DENY."
  }
}

variable "members" {
  description = "Artifact Registry Reader and Writer roles for Users/SAs. Key names must be readers and/or writers."
  type        = map(list(string))
  default     = {}
  validation {
    condition = alltrue([
      for key in keys(var.members) : contains(["readers", "writers"], key)
    ])
    error_message = "The supported keys are readers and writers."
  }
}
