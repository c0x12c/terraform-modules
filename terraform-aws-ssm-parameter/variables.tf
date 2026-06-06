################################################################################
# SSM Parameter
################################################################################

variable "prefix" {
  description = "Prefix of list of parameters"
  type        = string
}

variable "parameters" {
  description = "Map of parameter stores, the key is name of this value"
  type = map(object({
    # Value of the parameter.
    value = optional(string, null)
    # List of values of the parameter (will be jsonencoded to store as string natively in SSM).
    values = optional(list(string), [])
    # Description of the parameter.
    description = optional(string, null)
    # Enable insecure values 
    insecure = optional(bool, false)
    # Parameter tier to assign to the parameter. If not specified, will use the default parameter tier for the region. Valid tiers are Standard, Advanced, and Intelligent-Tiering. Downgrading an Advanced tier parameter to Standard will recreate the resource.
    tier = optional(string, "Standard")
    # KMS key ID or ARN for encrypting a parameter (when type is SecureString)
    key_id = optional(string, null)
    # Regular expression used to validate the parameter value.
    allowed_pattern = optional(string, null)
    # Data type of the parameter. Valid values: text, aws:ssm:integration and aws:ec2:image for AMI format.
    data_type = optional(string, "text")
  }))
  default = {}
}
