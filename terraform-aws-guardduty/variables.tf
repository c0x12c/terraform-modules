variable "name" {
  type        = string
  description = "The name of resources"
}

variable "enabled_guardduty" {
  description = "Whether enabling GuardDuty for IPS/IDS"
  type        = bool
  default     = false
}

variable "enabled_guardduty_s3_scanning" {
  description = "Whether enabling GuardDuty for scanning S3 logs"
  type        = bool
  default     = false
}

variable "enabled_guardduty_eks_audit" {
  description = "Whether enabling GuardDuty for scanning EKS Audit logs"
  type        = bool
  default     = false
}

variable "enabled_guardduty_ebs_malware_detection" {
  description = "Whether enabling GuardDuty for scanning EBS malware"
  type        = bool
  default     = false
}

variable "enabled_email_notification" {
  description = "Whether enabling GuardDuty notifications to emails"
  type        = bool
  default     = false
}

variable "notifications_received_email_list" {
  description = "List of emails to receive GuardDuty findings"
  type        = list(string)
  default     = []
}
